#!/usr/bin/env bash

# Lint & format helper for docs and config files
# - Markdown: autofix (markdownlint classic) + report (markdownlint-cli2)
# - JSON/ARB: validate + stable sort with jq
# - Link-check (lychee): opcionális, ha telepítve van
#
# Fő javítások ebben a verzióban:
# - node_modules/, build/, .git/, ios/Pods, android/.gradle, .dart_tool, .idea stb. kizárása MINDEN lépésből
# - Egységes, explicit fájllista (find) a markdown eszközök felé – nincs véletlen belenézés idegen könyvtárakba
# - .markdownlint.json abszolút útvonal (classic CLI), opcionális .markdownlintignore kezelés
# - Stabil pipefail + naplózás (tee), STRICT mód a riport hibákra
# - jq-s JSON/ARB rendezés csak whitelisted helyeken

set -u  # Szándékosan nincs 'set -e' (lint ne buktassa automatikusan a jobot)
IFS=$'\n\t'

# ---------------- Utils --------------------------------------------------
RED="\033[31m"; GREEN="\033[32m"; YELLOW="\033[33m"; BOLD="\033[1m"; RESET="\033[0m"
info()  { echo -e "${BOLD}ℹ️  $*${RESET}"; }
succ()  { echo -e "${GREEN}✅ $*${RESET}"; }
warn()  { echo -e "${YELLOW}⚠️  $*${RESET}"; }
fail()  { echo -e "${RED}❌ $*${RESET}"; }

# ---------------- Repo root ---------------------------------------------
if command -v git >/dev/null 2>&1 && git rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
fi
cd "$REPO_ROOT"
info "Repo root: $REPO_ROOT"

# ---------------- Settings ----------------------------------------------
STRICT_MARKDOWNLINT=${STRICT_MARKDOWNLINT:-false}

CONFIG_ARG=""
CONFIG_PATH="$REPO_ROOT/.markdownlint.json"
IGNORE_PATH="$REPO_ROOT/.markdownlintignore"
if [[ -f "$CONFIG_PATH" ]]; then
  CONFIG_ARG="-c \"$CONFIG_PATH\""
  info "Using markdownlint config: $CONFIG_PATH"
else
  warn ".markdownlint.json not found at $CONFIG_PATH (proceeding without explicit -c)"
fi

USE_IGNORE=false
if [[ -f "$IGNORE_PATH" ]]; then
  USE_IGNORE=true
  info "Using ignore file: $IGNORE_PATH"
fi

# ---------------- File lists --------------------------------------------
# Biztonságos, explicit fájllisták a szerszámoknak
mapfile -d '' MD_FILES < <(find "$REPO_ROOT" -type f -name '*.md' \
  -not -path '*/.git/*' \
  -not -path '*/node_modules/*' \
  -not -path '*/build/*' \
  -not -path '*/ios/Pods/*' \
  -not -path '*/android/.gradle/*' \
  -not -path '*/.dart_tool/*' \
  -not -path '*/.idea/*' \
  -print0)

mapfile -d '' JSON_ARB_FILES < <(find "$REPO_ROOT" \( -name '*.json' -o -name '*.arb' \) \
  -not -path '*/.git/*' \
  -not -path '*/node_modules/*' \
  -not -path '*/build/*' \
  -not -path '*/ios/Pods/*' \
  -not -path '*/android/.gradle/*' \
  -not -path '*/.dart_tool/*' \
  -not -path '*/.idea/*' \
  -print0)

if [[ ${#MD_FILES[@]} -eq 0 ]]; then
  warn "No Markdown files found after exclusions."
fi

# ---------------- Markdown autofix (classic) -----------------------------
MD_FIX_EXIT=0
if command -v markdownlint >/dev/null 2>&1 && [[ ${#MD_FILES[@]} -gt 0 ]]; then
  info "Running markdownlint --fix (autofix)…"
  set -o pipefail
  if [[ "$USE_IGNORE" == true ]]; then
    # shellcheck disable=SC2086
    xargs -0 markdownlint $CONFIG_ARG --fix --ignore-path "$IGNORE_PATH" < <(printf '%s\0' "${MD_FILES[@]}") | tee markdownlint_fix.log
  else
    # shellcheck disable=SC2086
    xargs -0 markdownlint $CONFIG_ARG --fix < <(printf '%s\0' "${MD_FILES[@]}") | tee markdownlint_fix.log
  fi
  MD_FIX_EXIT=${PIPESTATUS[0]}
  set +o pipefail
  if [[ $MD_FIX_EXIT -eq 0 ]]; then
    succ "markdownlint --fix completed."
  else
    warn "markdownlint --fix finished with issues (exit=$MD_FIX_EXIT)."
  fi
else
  warn "markdownlint (classic CLI) not found or no MD files. Skipping autofix."
fi

# ---------------- Markdown report (CLI2) ---------------------------------
MD_REPORT_EXIT=0
if command -v markdownlint-cli2 >/dev/null 2>&1 && [[ ${#MD_FILES[@]} -gt 0 ]]; then
  info "Running markdownlint-cli2 report…"
  set -o pipefail
  xargs -0 markdownlint-cli2 < <(printf '%s\0' "${MD_FILES[@]}") | tee markdownlint.log
  MD_REPORT_EXIT=${PIPESTATUS[0]}
  set +o pipefail
  if [[ $MD_REPORT_EXIT -eq 0 ]]; then
    succ "markdownlint-cli2 report: no issues."
  else
    warn "markdownlint-cli2 report found issues (exit=$MD_REPORT_EXIT). See markdownlint.log."
  fi
else
  warn "markdownlint-cli2 not found or no MD files. Skipping report."
fi

# ---------------- Link check (optional) ---------------------------------
if command -v lychee >/dev/null 2>&1 && [[ ${#MD_FILES[@]} -gt 0 ]]; then
  info "Running lychee (optional link check)…"
  set -o pipefail
  # A lychee-nek is explicit fájllistát adunk, így nem mászik bele a kizárt könyvtárakba.
  xargs -0 lychee --no-progress --format detailed --offline < <(printf '%s\0' "${MD_FILES[@]}") | tee lychee.log
  LYCHEE_EXIT=${PIPESTATUS[0]}
  set +o pipefail
  if [[ $LYCHEE_EXIT -eq 0 ]]; then
    succ "lychee: no broken links."
  else
    warn "lychee found link issues (exit=$LYCHEE_EXIT). See lychee.log."
  fi
else
  info "lychee not found or no MD files. Skipping link check."
fi

# ---------------- JSON/ARB format with jq -------------------------------
if ! command -v jq >/dev/null 2>&1; then
  warn "jq not found, skipping JSON/ARB formatting."
else
  if [[ ${#JSON_ARB_FILES[@]} -eq 0 ]]; then
    warn "No JSON/ARB files found after exclusions."
  else
    info "Formatting JSON/ARB files with jq (stable sort)…"
    for f in "${JSON_ARB_FILES[@]}"; do
      if jq -e . "$f" >/dev/null 2>&1; then
        tmp="${f}.tmp.$$"
        if jq -S '.' "$f" > "$tmp" 2>/dev/null; then
          mv "$tmp" "$f"
          echo "formatted: $f"
        else
          warn "failed to format: $f"; rm -f "$tmp"
        fi
      else
        warn "skip (non-strict JSON): $f"
      fi
    done
  fi
fi

succ "Docs lint finished."

# ---------------- Exit policy -------------------------------------------
# Alapértelmezés: nem buktatjuk a buildet. STRICT módban a riport hibakódjával lépünk ki.
if [[ "$STRICT_MARKDOWNLINT" == "true" && $MD_REPORT_EXIT -ne 0 ]]; then
  exit $MD_REPORT_EXIT
fi
exit 0
