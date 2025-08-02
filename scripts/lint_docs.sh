#!/usr/bin/env bash

# Lint & format helper for docs and config files
# - Markdown: autofix (markdownlint --fix) + report (markdownlint-cli2)
# - JSON/ARB: validate + stable sort with jq
# - Link-check (lychee): opcionális, ha telepítve van
#
# Változások ebben a verzióban:
# - ABSZOLÚT konfigurációs út a markdownlint klasszikus CLI-hez (-c <abs path>)
# - Stabil logolás (tee), pipefail a hibakód megőrzésére
# - JSON/ARB szűrés kiterjesztve: .git/, build/, node_modules/ kizárva
# - STRICT mód: ha STRICT_MARKDOWNLINT=true, hibára fut a job a riport hibáival

set -u  # 'set -e' SZÁNDÉKOSAN NINCS – nem akarjuk automatikusan megszakítani a lint miatt
IFS=$'\n\t'

# --- Utils ---------------------------------------------------------------
RED="\033[31m"; GREEN="\033[32m"; YELLOW="\033[33m"; BOLD="\033[1m"; RESET="\033[0m"
info()  { echo -e "${BOLD}ℹ️  $*${RESET}"; }
succ()  { echo -e "${GREEN}✅ $*${RESET}"; }
warn()  { echo -e "${YELLOW}⚠️  $*${RESET}"; }
fail()  { echo -e "${RED}❌ $*${RESET}"; }

# --- Repo root detektálás -----------------------------------------------
if command -v git >/dev/null 2>&1 && git rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  # fallback: a szkript könyvtára lesz a root
  REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
fi
cd "$REPO_ROOT"
info "Repo root: $REPO_ROOT"

# --- Beállítások --------------------------------------------------------
STRICT_MARKDOWNLINT=${STRICT_MARKDOWNLINT:-false}

# markdownlint (classic) config abszolút úttal; a régebbi verziók csak -c-t ismernek
CONFIG_ARG=""
CONFIG_PATH="$REPO_ROOT/.markdownlint.json"
if [[ -f "$CONFIG_PATH" ]]; then
  CONFIG_ARG="-c \"$CONFIG_PATH\""
  info "Using markdownlint config: $CONFIG_PATH"
else
  warn ".markdownlint.json not found at $CONFIG_PATH (proceeding without explicit -c)"
fi

# --- Markdown autofix (klasszikus CLI) ----------------------------------
MD_FIX_EXIT=0
if command -v markdownlint >/dev/null 2>&1; then
  info "Running markdownlint --fix (autofix)…"
  set -o pipefail
  # A bash -lc szükséges az idézőjelezett CONFIG_ARG biztonságos kiterjesztéséhez
  bash -lc "markdownlint '**/*.md' $CONFIG_ARG --fix | tee markdownlint_fix.log"
  MD_FIX_EXIT=${PIPESTATUS[0]}
  set +o pipefail
  if [[ $MD_FIX_EXIT -eq 0 ]]; then
    succ "markdownlint --fix completed."
  else
    warn "markdownlint --fix finished with issues (exit=$MD_FIX_EXIT)."
  fi
else
  warn "markdownlint (classic CLI) not found. Skipping autofix."
fi

# --- Markdown report (CLI2) ---------------------------------------------
MD_REPORT_EXIT=0
if command -v markdownlint-cli2 >/dev/null 2>&1; then
  info "Running markdownlint-cli2 report…"
  set -o pipefail
  markdownlint-cli2 "**/*.md" | tee markdownlint.log
  MD_REPORT_EXIT=${PIPESTATUS[0]}
  set +o pipefail
  if [[ $MD_REPORT_EXIT -eq 0 ]]; then
    succ "markdownlint-cli2 report: no issues."
  else
    warn "markdownlint-cli2 report found issues (exit=$MD_REPORT_EXIT). See markdownlint.log."
  fi
else
  warn "markdownlint-cli2 not found. Skipping report."
fi

# --- Link check (opcionális) --------------------------------------------
if command -v lychee >/dev/null 2>&1; then
  info "Running lychee (optional link check)…"
  set -o pipefail
  lychee --no-progress --offline --format detailed "**/*.md" | tee lychee.log
  LYCHEE_EXIT=${PIPESTATUS[0]}
  set +o pipefail
  if [[ $LYCHEE_EXIT -eq 0 ]]; then
    succ "lychee: no broken links."
  else
    warn "lychee found link issues (exit=$LYCHEE_EXIT). See lychee.log."
  fi
else
  info "lychee not found. Skipping link check (as requested)."
fi

# --- JSON/ARB formázás --------------------------------------------------
if ! command -v jq >/dev/null 2>&1; then
  warn "jq not found, skipping JSON/ARB formatting."
else
  info "Formatting JSON/ARB files with jq (stable sort)…"
  shopt -s globstar nullglob
  for f in **/*.json **/*.arb; do
    # Szűrés: .git/, build/, node_modules/ – kezeljük a vezető "./"-t is
    fp="${f#./}"
    case "$fp" in
      .git/*|build/*|node_modules/*) continue;;
    esac
    if jq -e . "$f" >/dev/null 2>&1; then
      tmp="${f}.tmp.$$"
      if jq -S '.' "$f" > "$tmp" 2>/dev/null; then
        mv "$tmp" "$f"
        echo "formatted: $f"
      else
        warn "failed to format: $f"
        rm -f "$tmp"
      fi
    else
      warn "skip (non-strict JSON): $f"
    fi
  done
  shopt -u globstar nullglob
fi

succ "Docs lint finished."

# --- Exit policy ---------------------------------------------------------
# Alapértelmezésben NEM buktatjuk a buildet (korábbi viselkedés megőrzése).
# Ha STRICT_MARKDOWNLINT=true, a report hibakódjával térünk vissza.
if [[ "$STRICT_MARKDOWNLINT" == "true" && $MD_REPORT_EXIT -ne 0 ]]; then
  exit $MD_REPORT_EXIT
fi
exit 0
