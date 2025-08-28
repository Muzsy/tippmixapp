#!/usr/bin/env bash
set -euo pipefail

# --- Projektváltozók: TÖLTSD KI ---
PROJECT="${PROJECT:-tippmix-dev}"           # TODO: állítsd be
REGION="${REGION:-europe-central2}"         # TODO: általában europe-central2
FUNC="${FUNC:-match_finalizer}"             # TODO
TOPIC="${TOPIC:-result-check}"              # TODO
SRC_DIR="${SRC_DIR:-cloud_functions}"       # TODO: ahol a CF kód van
RUNTIME="${RUNTIME:-nodejs20}"
ENTRY="${ENTRY:-match_finalizer}"           # TODO: belépési pont

gcloud config set project "$PROJECT" >/dev/null

echo "[i] Build (TS -> JS) if needed"
if [ -d "$SRC_DIR" ]; then
  pushd "$SRC_DIR" >/dev/null
  if [ -f package-lock.json ] || [ -f package.json ]; then
    npm ci || npm install
    npm run build || npm run build:prod || true
  fi
  popd >/dev/null
else
  echo "[!] SRC_DIR ($SRC_DIR) nem létezik — a deploy így is próbálkozik a mappával."
fi

echo "[i] Deploy GCF Gen2 (Pub/Sub trigger)"
gcloud functions deploy "$FUNC" \
  --gen2 \
  --region="$REGION" \
  --runtime="$RUNTIME" \
  --source="$SRC_DIR" \
  --entry-point="$ENTRY" \
  --trigger-topic="$TOPIC" \
  --quiet

echo "[i] Tesztüzenet a Pub/Sub topicra"
MSG='{"kind":"match-result-check","matchId":"LOCAL-TEST","ts":"'$(date -Is)'"}'
gcloud pubsub topics publish "$TOPIC" --message="$MSG" --attribute=source=local,env=dev >/dev/null

echo "[i] Logok (utolsó 3 perc)"
SINCE="$(date -u -d '3 minutes ago' +%Y-%m-%dT%H:%M:%SZ)"
LOGS=$(gcloud functions logs read "$FUNC" --region="$REGION" --min-log-level=INFO --start-time="$SINCE" --limit=200 || true)
echo "$LOGS" | tail -n 200

echo "[i] Gyors hibadetektálás"
if echo "$LOGS" | grep -E 'TypeError|ReferenceError|Unhandled|Invalid CloudEvent|Cannot read (properties|property) of undefined'; then
  echo "[!] Hiba észlelve a logban."; exit 1
fi

echo "[✓] match_finalizer kör OK"
