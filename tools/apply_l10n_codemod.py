import os, re, json

ROOT = os.path.join(os.path.dirname(__file__), '..', 'lib')
REPORT_PATH = os.path.join(os.path.dirname(__file__), 'l10n_report.json')

# Regex map for common UI string sites.
# We generate replacements that can take optional positional arguments when placeholders are present.
REPLACERS = [
    # Text('...')
    (re.compile(r"Text\(\s*'([^'\n]{2,})'\s*\)"),
     lambda key, ph, m: f"Text(context.l10n.{key}({', '.join(ph)}))" if ph else f"Text(context.l10n.{key})"),
    (re.compile(r'Text\(\s*"([^"\n]{2,})"\s*\)'),
     lambda key, ph, m: f"Text(context.l10n.{key}({', '.join(ph)}))" if ph else f"Text(context.l10n.{key})"),
    # labelText: '...'
    (re.compile(r"labelText:\s*'([^'\n]{2,})'"),
     lambda key, ph, m: f"labelText: context.l10n.{key}({', '.join(ph)})" if ph else f"labelText: context.l10n.{key}"),
    (re.compile(r'labelText:\s*"([^"\n]{2,})"'),
     lambda key, ph, m: f"labelText: context.l10n.{key}({', '.join(ph)})" if ph else f"labelText: context.l10n.{key}"),
    # hintText: '...'
    (re.compile(r"hintText:\s*'([^'\n]{2,})'"),
     lambda key, ph, m: f"hintText: context.l10n.{key}({', '.join(ph)})" if ph else f"hintText: context.l10n.{key}"),
    (re.compile(r'hintText:\s*"([^"\n]{2,})"'),
     lambda key, ph, m: f"hintText: context.l10n.{key}({', '.join(ph)})" if ph else f"hintText: context.l10n.{key}"),
    # SnackBar(content: Text('...'))
    (re.compile(r"SnackBar\(([^)]*?)Text\(\s*'([^'\n]{2,})'\s*\)"),
     lambda key, ph, m: f"SnackBar({m.group(1)}Text(context.l10n.{key}({', '.join(ph)})))" if ph else f"SnackBar({m.group(1)}Text(context.l10n.{key}))"),
    (re.compile(r'SnackBar\(([^)]*?)Text\(\s*"([^"\n]{2,})"\s*\)'),
     lambda key, ph, m: f"SnackBar({m.group(1)}Text(context.l10n.{key}({', '.join(ph)})))" if ph else f"SnackBar({m.group(1)}Text(context.l10n.{key}))"),
]

PLACEHOLDER_RX = re.compile(r"\$([a-zA-Z_]\w*)")  # $varName inside matched strings

def ensure_import(content: str) -> str:
    # ensure extension import for context.l10n
    line = "import 'package:notifica/core/prefs.dart';"
    if line not in content:
        return line + "\n" + content
    return content

def load_report():
    with open(REPORT_PATH, 'r', encoding='utf-8') as fh:
        return json.load(fh)

def apply_for_file(path: str, replacements: dict) -> bool:
    """
    replacements: dict[old_text] = {'key': str, 'placeholders': [str]}  (placeholders are raw names without '$')
    """
    changed = False
    with open(path, 'r', encoding='utf-8') as fh:
        content = fh.read()

    content = ensure_import(content)

    # Apply replacements by scanning each pattern and comparing group(1) with old_text
    for old_text, info in replacements.items():
        key = info['key'] if isinstance(info, dict) and 'key' in info else info
        ph = info.get('placeholders', []) if isinstance(info, dict) else []
        for rx, builder in REPLACERS:
            def _sub(m):
                captured = m.group(1)
                # Only transform the exact matched literal
                if captured != old_text:
                    return m.group(0)
                return builder(key, ph, m)
            content_new = rx.sub(_sub, content)
            if content_new != content:
                changed = True
                content = content_new

    if changed:
        with open(path, 'w', encoding='utf-8') as fh:
            fh.write(content)
    return changed

def main():
    report = load_report()
    # Group by file and prepare map of old_text -> {key, placeholders}
    by_file = {}
    for item in report:
        # Newer extractor may provide 'placeholders'; keep backward compat
        old = item['match']
        key = item['key']
        placeholders = item.get('placeholders', [])

        # If report didn't include placeholders, infer from old text (best-effort)
        if not placeholders:
            placeholders = PLACEHOLDER_RX.findall(old)

        by_file.setdefault(item['file'], {})[old] = {'key': key, 'placeholders': placeholders}

    total = 0
    for rel, repl in by_file.items():
        path = os.path.join(ROOT, rel)
        if not os.path.exists(path):
            continue
        if apply_for_file(path, repl):
            print(f"✔ Modificat: {rel}")
            total += 1
    print(f"Total fișiere modificate: {total}")

if __name__ == '__main__':
    main()