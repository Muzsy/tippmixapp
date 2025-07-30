#!/usr/bin/env bash
set -euo pipefail

echo "📄  Linting Markdown & docs …"

# 1. Markdownlint (GitHub style)
if command -v markdownlint >/dev/null 2>&1; then
  markdownlint "**/*.md"
else
  echo "⚠️  markdownlint not installed – skipping."
fi

# 2. Broken-link check (optional, requires lychee)
if command -v lychee >/dev/null 2>&1; then
  lychee --no-progress "**/*.md" || true   # non-fatal
fi

# 3. Arb / JSON formatting (l10n files)
find . -name "*.arb" -o -name "*.json" | while read -r f; do
  jq -S '.' "$f" >"$f.tmp" && mv "$f.tmp" "$f"
done

echo "✅  Docs lint finished."
