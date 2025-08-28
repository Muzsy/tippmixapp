#!/usr/bin/env bash
set -euo pipefail

PROJECT="${PROJECT:-tippmix-dev}"       # TODO
REGION="${REGION:-europe-central2}"     # TODO
FUNC="${FUNC:-match_finalizer}"         # TODO
TOPIC="${TOPIC:-result-check}"          # TODO

gcloud config set project "$PROJECT" >/dev/null

MSG='{"kind":"match-result-check","matchId":"QUICK-TEST","ts":"'$(date -Is)'"}'
gcloud pubsub topics publish "$TOPIC" --message="$MSG" --attribute=source=quick,env=dev >/dev/null

SINCE="$(date -u -d '2 minutes ago' +%Y-%m-%dT%H:%M:%SZ)"
LOGS=$(gcloud functions logs read "$FUNC" --region="$REGION" --min-log-level=INFO --start-time="$SINCE" --limit=120 || true)
echo "$LOGS" | tail -n 120

if echo "$LOGS" | grep -E 'TypeError|ReferenceError|Unhandled|Invalid CloudEvent|Cannot read (properties|property) of undefined'; then
  echo "[!] Hiba észlelve a logban."; exit 1
fi

echo "[✓] QUICK kör OK"
