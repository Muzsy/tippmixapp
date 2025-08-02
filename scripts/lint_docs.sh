#!/usr/bin/env bash
set -euo pipefail

echo "📄  Linting Markdown & docs …"

# 1) Markdownlint (nem kritikus)
if command -v markdownlint >/dev/null 2>&1; then
  # Ha mégis pirosra futna, ne bukjon a pipeline ezen
  markdownlint '**/*.md' || echo "⚠️  markdownlint found issues (non-fatal)."
else
  echo "⚠️  markdownlint not installed – skipping."
fi

# 2) Broken-link check (nem kritikus)
if command -v lychee >/dev/null 2>&1; then
  lychee --no-progress '**/*.md' || echo "⚠️  lychee found issues (non-fatal)."
fi

# 3) ARB / JSON formázás – csak valid, valódi JSON fájlokra
#   - Kihagyjuk a .git, build, node_modules mappákat
#   - JSONC/JSON5 fájlokat (kommentes) átugorjuk

mapfile -d '' FILES < <(
  find . -type f \
    \( -name '*.arb' -o -name '*.json' \) \
    -not -path './.git/*' \
    -not -path './build/*' \
    -not -path './node_modules/*' \
    -print0
)

for f in "${FILES[@]}"; do
  # Ellenőrizzük, hogy tényleg érvényes JSON (jq -e . csak valid JSON-ra 0 exit)
  if jq -e . "$f" >/dev/null 2>&1; then
    tmp="$(mktemp)"
    if jq -S '.' "$f" >"$tmp"; then
      mv "$tmp" "$f"
    else
      echo "⚠️  jq failed to format $f – skipping."
      rm -f "$tmp"
    fi
  else
    echo "⚠️  Skipping non-strict JSON (maybe JSONC/JSON5?): $f"
  fi
done

echo "✅  Docs lint finished."
