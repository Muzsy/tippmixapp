#!/usr/bin/env bash
set -euo pipefail

# Simple smoke test for the claim_daily_bonus Edge Function.
#
# Usage examples:
#  1) With existing user JWT (best when you are logged in already):
#     USER_JWT="<paste jwt>" ./tools/smoke_claim_daily_bonus.sh
#
#  2) With email/password to obtain JWT via GoTrue:
#     SUPABASE_TEST_EMAIL="you@example.com" \
#     SUPABASE_TEST_PASSWORD="YourPassword123" \
#     ./tools/smoke_claim_daily_bonus.sh
#
# Optional envs:
#  SUPABASE_URL               (defaults to .env value)
#  SUPABASE_ANON_KEY          (defaults to .env value)
#  SUPABASE_SERVICE_ROLE_KEY  (optional, only used for admin verification)
#  USER_ID                    (optional, used for verification query when SERVICE_ROLE is present)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load .env if present to populate SUPABASE_URL and SUPABASE_ANON_KEY
if [[ -f "$ROOT_DIR/.env" ]]; then
  # shellcheck disable=SC2046
  export $(grep -E '^(SUPABASE_URL|SUPABASE_ANON_KEY)=' "$ROOT_DIR/.env" | xargs -d '\n') || true
fi

SUPABASE_URL=${SUPABASE_URL:-}
SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY:-}

if [[ -z "${SUPABASE_URL}" || -z "${SUPABASE_ANON_KEY}" ]]; then
  echo "[ERR] SUPABASE_URL or SUPABASE_ANON_KEY missing. Export them or add to .env" >&2
  exit 1
fi

AUTH_TOKEN=${USER_JWT:-}

if [[ -z "${AUTH_TOKEN}" ]]; then
  if [[ -n "${SUPABASE_TEST_EMAIL:-}" && -n "${SUPABASE_TEST_PASSWORD:-}" ]]; then
    echo "[INFO] Obtaining user access_token via password grant..."
    AUTH_TOKEN=$(curl -sS -X POST \
      -H "apikey: ${SUPABASE_ANON_KEY}" \
      -H "Content-Type: application/json" \
      -d "{\"email\":\"${SUPABASE_TEST_EMAIL}\",\"password\":\"${SUPABASE_TEST_PASSWORD}\"}" \
      "${SUPABASE_URL}/auth/v1/token?grant_type=password" | jq -r '.access_token // empty')
    if [[ -z "${AUTH_TOKEN}" ]]; then
      echo "[ERR] Failed to obtain access_token. Check email/password or auth settings." >&2
      exit 1
    fi
  else
    cat << 'USAGE' >&2
[ERR] No USER_JWT nor SUPABASE_TEST_EMAIL/PASSWORD provided.
Provide one of:
  - USER_JWT="<paste current user JWT>"
  - SUPABASE_TEST_EMAIL="you@example.com" SUPABASE_TEST_PASSWORD="YourPassword123"
USAGE
    exit 1
  fi
fi

echo "[INFO] Calling claim_daily_bonus..."
RESP1=$(curl -sS -X POST \
  -H "Authorization: Bearer ${AUTH_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  "${SUPABASE_URL}/functions/v1/claim_daily_bonus")
echo "[RESP-1] ${RESP1}"

echo "[INFO] Calling claim_daily_bonus again to test idempotency..."
RESP2=$(curl -sS -X POST \
  -H "Authorization: Bearer ${AUTH_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  "${SUPABASE_URL}/functions/v1/claim_daily_bonus")
echo "[RESP-2] ${RESP2}"

# Optional verification: query the latest daily_bonus ledger row.
echo "[INFO] Verifying coins_ledger (owner read via user JWT)..."
LEDGER=$(curl -sS -X GET \
  -H "Authorization: Bearer ${AUTH_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  "${SUPABASE_URL}/rest/v1/coins_ledger?select=id,delta,type,balance_after,created_at&order=created_at.desc.nullslast&limit=1")
echo "[LEDGER] ${LEDGER}"

echo "[DONE] Smoke test completed."

