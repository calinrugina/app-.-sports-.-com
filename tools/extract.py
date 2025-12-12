#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Extract hardcoded UI strings from lib/*.dart into lib/l10n/app_en.arb

- Detects placeholders like $var and converts to {var} in ARB
- Emits @key metadata with placeholders/types
- Writes/merges tools/l10n_report.json with file, match, key, placeholders
- Heuristics to also extract strings from validators:
  * errorText: '...'/ "..."
  * return '...'; / "..." inside validator-like contexts (see VALIDATOR_HINTS)

NEW (v2):
- Extracts common named-argument strings: title:, subtitle:, label:, text:, message:, etc.
- Optional fallback extractor for "any string literal" near UI-ish hints (OFF by default)
- Better handling of multi-line strings and basic Dart escaping
"""

import os
import re
import json
import sys
import hashlib
import unicodedata

# --------- Config ---------
USE_HASH_SUFFIX = True    # add _<hash> to key to avoid collisions
ARB_LOCALE = "en"
EXCLUDE_DIR_NAMES = {
    ".dart_tool", ".idea", ".git", "build", "ios", "android",
    "linux", "macos", "windows", "web", "test", "example",
    "flutter_gen"
}
VALIDATOR_CONTEXT_WINDOW = 200  # chars to look back for validator hints
VALIDATOR_HINTS = (
    "validate", "validator", "FormFieldValidator", "TextFormField(",
    "String? _validate", "String? validate", "String Function", "Form("
)

# Optional: very aggressive fallback extractor (OFF by default)
ENABLE_FALLBACK_ANY_STRING = False

# ---------- Path helpers ----------
def find_project_root(start_dir: str) -> str:
    cur = os.path.abspath(start_dir)
    while True:
        if os.path.isfile(os.path.join(cur, "pubspec.yaml")):
            return cur
        parent = os.path.dirname(cur)
        if parent == cur:
            return os.path.abspath(os.path.join(start_dir, ".."))
        cur = parent

THIS_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = find_project_root(THIS_DIR)
LIB_DIR = os.path.join(PROJECT_ROOT, "lib")
L10N_DIR = os.path.join(LIB_DIR, "l10n")
ARB_PATH = os.path.join(L10N_DIR, f"app_{ARB_LOCALE}.arb")
REPORT_PATH = os.path.join(PROJECT_ROOT, "tools", "l10n_report.json")

# ---------- Key building with diacritics stripping ----------
_DIACRITIC_MAP = {
    'ă': 'a', 'â': 'a', 'î': 'i', 'ș': 's', 'ş': 's', 'ț': 't', 'ţ': 't',
    'Ă': 'A', 'Â': 'A', 'Î': 'I', 'Ș': 'S', 'Ş': 'S', 'Ț': 'T', 'Ţ': 'T',
}

def _strip_diacritics(text: str) -> str:
    nfd = unicodedata.normalize('NFD', text)
    no_marks = ''.join(ch for ch in nfd if unicodedata.category(ch) != 'Mn')
    return ''.join(_DIACRITIC_MAP.get(ch, ch) for ch in no_marks)

def slug_key(s: str, existing_keys: set = None) -> str:
    normalized = _strip_diacritics(s)
    base = re.sub(r'[^a-zA-Z0-9]+', '_', normalized.strip()).strip('_').lower()
    base = base[:40] if base else 'text'

    if existing_keys is None:
        return base

    if base not in existing_keys:
        return base

    h = hashlib.md5(s.encode('utf-8')).hexdigest()[:6]
    return f"{base}_{h}"

# ---------- Patterns ----------
# UI sites (your original patterns)
PATTERNS = [
    r"Text\(\s*'([^'\n]{2,})'\s*\)",
    r'Text\(\s*"([^"\n]{2,})"\s*\)',
    r"labelText:\s*'([^'\n]{2,})'",
    r'labelText:\s*"([^"\n]{2,})"',
    r"hintText:\s*'([^'\n]{2,})'",
    r'hintText:\s*"([^"\n]{2,})"',
    r"errorText:\s*'([^'\n]{2,})'",
    r'errorText:\s*"([^"\n]{2,})"',
    r"SnackBar\([^)]*?Text\(\s*'([^'\n]{2,})'\s*\)",
    r'SnackBar\([^)]*?Text\(\s*"([^"\n]{2,})"\s*\)',
    r"Tooltip\(\s*'([^'\n]{2,})'\s*\)",
    r'Tooltip\(\s*"([^"\n]{2,})"\s*\)',
    r"AppBar\(\s*title:\s*Text\(\s*'([^'\n]{2,})'\s*\)",
    r'AppBar\(\s*title:\s*Text\(\s*"([^"\n]{2,})"\s*\)',
]
COMPILED = [re.compile(p) for p in PATTERNS]

# Validator & general literal return patterns (we will filter by context)
RETURN_SINGLE = re.compile(r"return\s*'([^'\n]{2,})'\s*;")
RETURN_DOUBLE = re.compile(r'return\s*"([^"\n]{2,})"\s*;')

PLACEHOLDER_RX = re.compile(r"\$([a-zA-Z_]\w*)")

# ---------- NEW: Generic named-argument extractor ----------
NAMED_ARG_KEYS = (
    "title", "subtitle", "label", "text", "message", "hint",
    "header", "subheader", "emptyText", "error", "tooltip",
    "confirmText", "cancelText", "okText", "buttonText",
)

# title: '...' or "..." across newlines, including escaped quotes
NAMED_ARG_RX = re.compile(
    r"(?:(?:" + "|".join(NAMED_ARG_KEYS) + r")\s*:\s*)"
    r"(?P<q>['\"])(?P<s>(?:\\.|(?!\1).){2,})\1",
    re.DOTALL
)

# ---------- NEW: Optional fallback: any string literal (guarded) ----------
ANY_STRING_RX = re.compile(
    r"(?P<q>['\"])(?P<s>(?:\\.|(?!\1).){2,})\1",
    re.DOTALL
)

SKIP_STRING_PREFIXES = (
    "http://", "https://", "assets/", "packages/", "data:",
)
SKIP_LIKE_CODE_RX = re.compile(r"^[A-Z0-9_]{2,}$")  # e.g. SOME_ENUM, KEY_NAME
SKIP_FILE_EXT_RX = re.compile(
    r".*\.(png|jpg|jpeg|webp|svg|json|arb|mp4|m3u8|vtt|srt)$",
    re.IGNORECASE
)

def is_generated_or_excluded(path: str) -> bool:
    parts = set(os.path.normpath(path).split(os.sep))
    if any(d in EXCLUDE_DIR_NAMES for d in parts):
        return True
    if os.path.commonpath([LIB_DIR, path]) != LIB_DIR:
        return True
    if not path.endswith(".dart"):
        return True
    if os.path.join("lib", "l10n") in path and path.endswith(".dart"):
        return True
    return False

def load_existing_arb() -> dict:
    if os.path.isfile(ARB_PATH):
        with open(ARB_PATH, "r", encoding="utf-8") as fh:
            try:
                data = json.load(fh)
                return data if isinstance(data, dict) else {}
            except Exception:
                return {}
    return {}

def ensure_dirs():
    os.makedirs(L10N_DIR, exist_ok=True)
    os.makedirs(os.path.dirname(REPORT_PATH), exist_ok=True)

def handle_match(text: str):
    """Return (arb_value, placeholders) after processing $vars."""
    text = text.strip()
    if len(text) < 2:
        return None, None
    if text.startswith("http"):
        return None, None
    ph_names = PLACEHOLDER_RX.findall(text)
    arb_value = text
    if ph_names:
        for name in sorted(set(ph_names), key=ph_names.index):
            arb_value = arb_value.replace(f"${name}", f"{{{name}}}")
    # unique, preserve order
    return arb_value, list(dict.fromkeys(ph_names))

def _unescape_dart_string(s: str) -> str:
    # minimal unescape for common sequences
    return (s.replace(r"\n", "\n")
             .replace(r"\t", "\t")
             .replace(r"\'", "'")
             .replace(r"\"", '"')
             .replace(r"\\", "\\"))

def should_skip_literal(text: str) -> bool:
    t = text.strip()
    if len(t) < 2:
        return True
    if any(t.startswith(p) for p in SKIP_STRING_PREFIXES):
        return True
    if SKIP_FILE_EXT_RX.match(t):
        return True
    if SKIP_LIKE_CODE_RX.match(t):
        return True
    if t.startswith("@") or t.startswith("#"):
        return True
    # common "not UI" patterns
    if t.startswith("BEGIN:VEVENT") or t.startswith("RRULE:"):
        return True
    return False

def add_entry(rel_file: str, raw_text: str, entries: dict, metas: dict, report: list, description: str = ""):
    raw_text = raw_text.strip()
    processed = handle_match(raw_text)
    if not processed or processed[0] is None:
        return
    arb_value, ph_names = processed
    key = slug_key(raw_text, entries.keys())

    if key not in entries:
        entries[key] = arb_value
        meta_key = f"@{key}"
        if ph_names:
            metas[meta_key] = {
                "description": description,
                "placeholders": {n: {"type": "String"} for n in ph_names}
            }
        elif description:
            metas.setdefault(meta_key, {"description": description})

    report.append({
        "file": rel_file,
        "match": raw_text,
        "key": key,
        "placeholders": ph_names or []
    })

def main():
    ensure_dirs()
    entries = {}
    metas = {}
    report = []

    # scan lib/
    for root, _, files in os.walk(LIB_DIR):
        for fname in files:
            path = os.path.join(root, fname)
            if is_generated_or_excluded(path):
                continue
            try:
                with open(path, "r", encoding="utf-8") as fh:
                    content = fh.read()
            except UnicodeDecodeError:
                continue

            rel = os.path.relpath(path, LIB_DIR).replace(os.sep, "/")

            # 1) UI patterns (original)
            for rx in COMPILED:
                for m in rx.finditer(content):
                    text = (m.group(1) or "").strip()
                    processed = handle_match(text)
                    if not processed or processed[0] is None:
                        continue
                    arb_value, ph_names = processed
                    key = slug_key(text, entries.keys())
                    if key not in entries:
                        entries[key] = arb_value
                        if ph_names:
                            metas[f"@{key}"] = {
                                "description": "",
                                "placeholders": {n: {"type": "String"} for n in ph_names}
                            }
                    report.append({
                        "file": rel,
                        "match": text,
                        "key": key,
                        "placeholders": ph_names or []
                    })

            # 1.5) NEW: Named arguments like title:, subtitle:, label:, text: ...
            for m in NAMED_ARG_RX.finditer(content):
                s = _unescape_dart_string(m.group("s") or "").strip()
                if should_skip_literal(s):
                    continue
                add_entry(rel, s, entries, metas, report, description="Named argument text")

            # 1.6) OPTIONAL: Fallback - any string literal, but guarded by UI hints
            if ENABLE_FALLBACK_ANY_STRING:
                for m in ANY_STRING_RX.finditer(content):
                    s = _unescape_dart_string(m.group("s") or "").strip()
                    if should_skip_literal(s):
                        continue

                    window_from = max(0, m.start() - 120)
                    window_to = min(len(content), m.end() + 120)
                    around = content[window_from:window_to]

                    ui_hints = (
                        "Text(", "title:", "subtitle:", "labelText:", "hintText:",
                        "SnackBar", "ListTile", "AppBar", "Dialog",
                        "ElevatedButton", "OutlinedButton", "TextButton",
                        "WelcomeBanner(", "SectionHeader(", "Scaffold("
                    )
                    if not any(h in around for h in ui_hints):
                        continue

                    add_entry(rel, s, entries, metas, report, description="Generic UI-ish string")

            # 2) Validator returns (heuristic)
            for rx in (RETURN_SINGLE, RETURN_DOUBLE):
                for m in rx.finditer(content):
                    start = m.start()
                    ctx_from = max(0, start - VALIDATOR_CONTEXT_WINDOW)
                    ctx = content[ctx_from:start]
                    if not any(h in ctx for h in VALIDATOR_HINTS):
                        continue
                    text = (m.group(1) or "").strip()
                    processed = handle_match(text)
                    if not processed or processed[0] is None:
                        continue
                    arb_value, ph_names = processed
                    key = slug_key(text, entries.keys())
                    if key not in entries:
                        entries[key] = arb_value
                        if ph_names:
                            metas[f"@{key}"] = {
                                "description": "Validator message",
                                "placeholders": {n: {"type": "String"} for n in ph_names}
                            }
                    report.append({
                        "file": rel,
                        "match": text,
                        "key": key,
                        "placeholders": ph_names or []
                    })

    # merge with existing ARB
    arb = load_existing_arb()
    arb.setdefault("@@locale", ARB_LOCALE)

    added = 0
    for k, v in entries.items():
        if k not in arb:
            arb[k] = v
            added += 1
        meta_key = f"@{k}"
        if meta_key not in arb and meta_key in metas:
            arb[meta_key] = metas[meta_key]

    # write ARB with stable key order
    with open(ARB_PATH, "w", encoding="utf-8") as fh:
        ordered_keys = ["@@locale"] + sorted([k for k in arb.keys() if k != "@@locale"])
        ordered = {k: arb[k] for k in ordered_keys if k in arb}
        json.dump(ordered, fh, ensure_ascii=False, indent=2)

    with open(REPORT_PATH, "w", encoding="utf-8") as fh:
        json.dump(report, fh, ensure_ascii=False, indent=2)

    print(f"Project root   : {PROJECT_ROOT}")
    print(f"Scanning dir   : {LIB_DIR}")
    print(f"ARB written    : {ARB_PATH}")
    print(f"Report written : {REPORT_PATH}")
    print(f"New keys added : {added}")
    print(f"Total report items: {len(report)}")
    print(f"Fallback ANY_STRING enabled: {ENABLE_FALLBACK_ANY_STRING}")

if __name__ == "__main__":
    sys.exit(main() or 0)