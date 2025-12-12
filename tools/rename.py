#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import re
import json

THIS_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(THIS_DIR, ".."))

LIB_ROOT = os.path.join(PROJECT_ROOT, "lib")

# Try multiple possible locations for the report
REPORT_CANDIDATES = [
    os.path.join(PROJECT_ROOT, "tools", "l10n_report.json"),
    os.path.join(THIS_DIR, "l10n_report.json"),
]

IMPORT_LINE = "import 'package:sports_config_app/l10n/app_localizations.dart';"

PLACEHOLDER_RX = re.compile(r"\$([a-zA-Z_]\w*)")  # $varName

# --- Helpers --------------------------------------------------------------

def load_report():
    for p in REPORT_CANDIDATES:
        if os.path.exists(p):
            with open(p, "r", encoding="utf-8") as fh:
                data = json.load(fh)
                print(f"Using report: {p} (items={len(data)})")
                return data
    raise FileNotFoundError(
        f"Could not find l10n_report.json in: {REPORT_CANDIDATES}"
    )

def ensure_import(content: str) -> str:
    if IMPORT_LINE in content:
        return content
    # insert after library / first imports block
    lines = content.splitlines(True)
    insert_at = 0
    # skip leading comments / empty lines
    while insert_at < len(lines) and (lines[insert_at].strip().startswith("//") or lines[insert_at].strip() == ""):
        insert_at += 1
    # if file starts with "library ..." keep it
    if insert_at < len(lines) and lines[insert_at].lstrip().startswith("library "):
        insert_at += 1
    # insert after existing imports
    while insert_at < len(lines) and lines[insert_at].lstrip().startswith("import "):
        insert_at += 1
    lines.insert(insert_at, IMPORT_LINE + "\n")
    return "".join(lines)

def build_call(key: str, placeholders: list[str]) -> str:
    if placeholders:
        return f"AppLocalizations.of(context)!.{key}({', '.join(placeholders)})"
    return f"AppLocalizations.of(context)!.{key}"

def normalize_match_for_compare(s: str) -> str:
    # keep it simple: trim
    return (s or "").strip()

# --- Replacements ---------------------------------------------------------
# We do *targeted* replacements for known UI contexts.

CONTEXT_PATTERNS = [
    # Text('...')
    ("Text", re.compile(r"Text\(\s*'(?P<s>(?:\\.|[^'\\])+)'\s*\)")),
    ("Text", re.compile(r'Text\(\s*"(?P<s>(?:\\.|[^"\\])+)\"\s*\)')),

    # labelText: '...'
    ("labelText", re.compile(r"labelText\s*:\s*'(?P<s>(?:\\.|[^'\\])+)'\s*")),
    ("labelText", re.compile(r'labelText\s*:\s*"(?P<s>(?:\\.|[^"\\])+)\"\s*')),

    # hintText: '...'
    ("hintText", re.compile(r"hintText\s*:\s*'(?P<s>(?:\\.|[^'\\])+)'\s*")),
    ("hintText", re.compile(r'hintText\s*:\s*"(?P<s>(?:\\.|[^"\\])+)\"\s*')),

    # errorText: '...'
    ("errorText", re.compile(r"errorText\s*:\s*'(?P<s>(?:\\.|[^'\\])+)'\s*")),
    ("errorText", re.compile(r'errorText\s*:\s*"(?P<s>(?:\\.|[^"\\])+)\"\s*')),

    # SnackBar(... Text('...') ...)
    # NOTE: string is s group; we keep prefix in other groups if needed
    ("SnackBarText", re.compile(r"SnackBar\((?P<prefix>[\s\S]*?)Text\(\s*'(?P<s>(?:\\.|[^'\\])+)'\s*\)", re.MULTILINE)),
    ("SnackBarText", re.compile(r"SnackBar\((?P<prefix>[\s\S]*?)Text\(\s*\"(?P<s>(?:\\.|[^\"\\])+)\"\s*\)", re.MULTILINE)),

    # Tooltip('...')
    ("Tooltip", re.compile(r"Tooltip\(\s*'(?P<s>(?:\\.|[^'\\])+)'\s*\)")),
    ("Tooltip", re.compile(r'Tooltip\(\s*"(?P<s>(?:\\.|[^"\\])+)\"\s*\)')),

    # Named args: title: '...', subtitle: "..."
    ("namedArg", re.compile(r"(?P<name>title|subtitle|label|text|message)\s*:\s*'(?P<s>(?:\\.|[^'\\])+)'\s*", re.MULTILINE)),
    ("namedArg", re.compile(r'(?P<name>title|subtitle|label|text|message)\s*:\s*"(?P<s>(?:\\.|[^"\\])+)\"\s*', re.MULTILINE)),
]

def apply_for_file(abs_path: str, items: list[dict]) -> int:
    with open(abs_path, "r", encoding="utf-8") as fh:
        content = fh.read()

    original = content
    content = ensure_import(content)

    # Build lookup: match_text -> (key, placeholders)
    lookup = {}
    for it in items:
        old = normalize_match_for_compare(it.get("match", ""))
        if not old:
            continue
        key = it.get("key")
        ph = it.get("placeholders") or PLACEHOLDER_RX.findall(old)
        lookup[old] = (key, ph)

    replacements_done = 0

    for _, rx in CONTEXT_PATTERNS:
        def _sub(m):
            nonlocal replacements_done
            s = normalize_match_for_compare(m.group("s"))
            if s not in lookup:
                return m.group(0)

            key, ph = lookup[s]
            call = build_call(key, ph)

            text = m.group(0)

            # Decide replacement based on the matched context
            if text.lstrip().startswith("Text("):
                return f"Text({call})"

            # labelText/hintText/errorText
            if "labelText" in text:
                return re.sub(r"labelText\s*:\s*(['\"]).*?\1", f"labelText: {call}", text, count=1, flags=re.DOTALL)
            if "hintText" in text:
                return re.sub(r"hintText\s*:\s*(['\"]).*?\1", f"hintText: {call}", text, count=1, flags=re.DOTALL)
            if "errorText" in text:
                return re.sub(r"errorText\s*:\s*(['\"]).*?\1", f"errorText: {call}", text, count=1, flags=re.DOTALL)

            # Tooltip(...)
            if text.lstrip().startswith("Tooltip("):
                return f"Tooltip({call})"

            # SnackBar(... Text(...) ...)
            if "SnackBar(" in text and "Text(" in text:
                # Replace only inside Text(...)
                # keep everything before/after intact
                return re.sub(
                    r"Text\(\s*(['\"]).*?\1\s*\)",
                    f"Text({call})",
                    text,
                    count=1,
                    flags=re.DOTALL
                )

            # named args title/subtitle/...
            if re.match(r"\s*(title|subtitle|label|text|message)\s*:", text):
                name = m.group("name")
                return f"{name}: {call}"

            return m.group(0)

        new_content, n = rx.subn(_sub, content)
        if n:
            # IMPORTANT: subn counts matches attempted, not actual changes;
            # we detect changes by comparing content
            if new_content != content:
                # estimate real replacement count by diff in string occurrences is hard;
                # we increment by number of exact replaced matches:
                # easiest: count how many of our calls we injected
                pass
            content = new_content

    # Count actual injected calls as replacements
    # (rough but reliable enough)
    for old, (key, ph) in lookup.items():
        call = build_call(key, ph)
        if call in content and old in original:
            # might be multiple occurrences; count by how many old literals remain in same contexts is complex
            # we count at least 1 replacement when call is present.
            pass

    # Compute a better replacement count by diffing number of old literal occurrences in contexts
    # We'll do a simple approximation: for each old literal, count exact quote occurrences decrease.
    for old in lookup.keys():
        old_single = f"'{old}'"
        old_double = f"\"{old}\""
        before = original.count(old_single) + original.count(old_double)
        after = content.count(old_single) + content.count(old_double)
        if after < before:
            replacements_done += (before - after)

    if content != original:
        with open(abs_path, "w", encoding="utf-8") as fh:
            fh.write(content)

    return replacements_done

def main():
    report = load_report()

    # group items by file
    by_file: dict[str, list[dict]] = {}
    for it in report:
        rel = it.get("file")
        if not rel:
            continue
        by_file.setdefault(rel, []).append(it)

    total_files = 0
    total_repls = 0

    for rel, items in by_file.items():
        abs_path = os.path.join(LIB_ROOT, rel)
        if not os.path.exists(abs_path):
            continue

        n = apply_for_file(abs_path, items)
        if n > 0:
            print(f"✔ Modified: {rel}  (replacements: {n})")
            total_files += 1
            total_repls += n
        else:
            # Helpful debug line
            print(f"· No changes: {rel} (items: {len(items)})")

    print(f"\nDONE. Files modified: {total_files}, total replacements: {total_repls}")

if __name__ == "__main__":
    main()