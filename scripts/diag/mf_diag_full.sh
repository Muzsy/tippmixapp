#!/usr/bin/env bash
# mf_diag_full.sh - Teljeskörű diagnosztika a match_finalizer Gen2 Cloud Functionhöz
# Írta: ChatGPT (TippmixApp hibadiagnózis)
# Követelmények: gcloud, jq (opcionális, de ajánlott)

set -euo pipefail

# ======= Alapértelmezések =======
PROJECT=""
REGION="europe-central2"
FUNC="match_finalizer"       # Cloud Functions erőforrás neve (gen2)
SERVICE="match-finalizer"    # Cloud Run service neve (gen2 CF alatt kötőjeles)
TOPIC="result-check"
WINDOW="2h"                  # log időablak: pl. 1h, 2h, 6h, 24h
PUBLISH_TEST="false"
REDACT="true"                # érzékeny értékek kitakarása
EXTRA_LIMIT=200              # log sorlimit

# ======= Paraméterek =======
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT="$2"; shift 2;;
    --region) REGION="$2"; shift 2;;
    --func) FUNC="$2"; shift 2;;
    --service) SERVICE="$2"; shift 2;;
    --topic) TOPIC="$2"; shift 2;;
    --window) WINDOW="$2"; shift 2;;
    --publish-test) PUBLISH_TEST="true"; shift 1;;
    --no-publish) PUBLISH_TEST="false"; shift 1;;
    --no-redact) REDACT="false"; shift 1;;
    --limit) EXTRA_LIMIT="$2"; shift 2;;
    *) echo "Ismeretlen paraméter: $1"; exit 1;;
  esac
done

command -v gcloud >/dev/null 2>&1 || { echo "HIBA: gcloud nincs telepítve."; exit 2; }
if ! command -v jq >/dev/null 2>&1; then
  echo "Megjegyzés: jq nincs telepítve; JSON tömböket nyersen fogok kiírni."
fi

if [[ -z "$PROJECT" ]]; then
  PROJECT="$(gcloud config get-value project 2>/dev/null || true)"
  if [[ -z "$PROJECT" || "$PROJECT" == "(unset)" ]]; then
    echo "HIBA: nincs --project megadva és a gcloud configban sincs projekt."
    exit 3
  fi
fi

DATE_STR="$(date +%Y%m%d_%H%M%S)"
OUT="mf_diag_${PROJECT}_${REGION}_${FUNC}_${DATE_STR}.log"

# minden STDOUT/STDERR a fájlba is menjen
exec > >(tee -a "$OUT") 2>&1

echo "=== MATCH FINALIZER DIAGNOSZTIKA ==="
echo "Dátum: $(date -Is)"
echo "Projekt: $PROJECT | Régió: $REGION | Function: $FUNC | Service: $SERVICE | Topic: $TOPIC"
echo "Időablak logokra: $WINDOW | Teszt üzenet: $PUBLISH_TEST | Redact: $REDACT"
echo "Kimeneti fájl: $OUT"
echo

# ------ WINDOW -> abszolút UTC cutoff (RFC3339) ------
window_cutoff_rfc3339() {
  local win="$1"
  local n
  case "$win" in
    *h) n="${win%h}";   date -u -d "${n} hours ago"   +%Y-%m-%dT%H:%M:%SZ ;;
    *m) n="${win%m}";   date -u -d "${n} minutes ago" +%Y-%m-%dT%H:%M:%SZ ;;
    *d) n="${win%d}";   date -u -d "${n} days ago"    +%Y-%m-%dT%H:%M:%SZ ;;
    *)                    date -u -d "2 hours ago"      +%Y-%m-%dT%H:%M:%SZ ;;
  esac
}
CUTOFF="$(window_cutoff_rfc3339 "$WINDOW")"
echo "Időablak kezdete (UTC): $CUTOFF"

echo
# ------ Helper: redaction ------
redact() {
  if [[ "$REDACT" == "true" ]]; then
    sed -E 's/([A-Z0-9_]*(KEY|TOKEN|SECRET)[A-Z0-9_]*: )[^"]+/\1***REDACTED***/g; s/(ODDS_API_KEY=)[^, "]+/\1***REDACTED***/g'
  else
    cat
  fi
}

# ------ Alap info ------
echo ">> gcloud verzió & aktív beállítások"
gcloud --version
gcloud config list
echo

echo ">> Projekt meta"
gcloud projects describe "$PROJECT" --format="yaml(projectId,projectNumber,name,labels)"
PROJECT_NUMBER="$(gcloud projects describe "$PROJECT" --format='value(projectNumber)')"
echo "PROJECT_NUMBER: $PROJECT_NUMBER"
echo

echo ">> Engedélyezett API-k (részlet)"
gcloud services list --enabled --project="$PROJECT" | head -n 200
echo

# ------ Cloud Functions Gen2 leírás ------
echo ">> Cloud Function (Gen2) describe (TELJES YAML)"
gcloud functions describe "$FUNC" \
  --region="$REGION" --gen2 --project="$PROJECT" --format="yaml" | redact
echo

# ------ Eventarc ------
echo ">> Eventarc triggerek listája (régió: $REGION)"
gcloud eventarc triggers list --location="$REGION" --project="$PROJECT"
echo

echo ">> Eventarc triggerek részletes leírása"
while read -r TNAME; do
  [[ -z "$TNAME" ]] && continue
  echo "--- trigger: $TNAME ---"
  gcloud eventarc triggers describe "$TNAME" --location="$REGION" --project="$PROJECT" --format="yaml"
done < <(gcloud eventarc triggers list --location="$REGION" --project="$PROJECT" --format="value(name)" || true)
echo

# ------ Cloud Run ------
echo ">> Cloud Run service státusz (revízió + forgalom + annotációk)"
gcloud run services describe "$SERVICE" \
  --region="$REGION" --project="$PROJECT" \
  --format="yaml(status.latestReadyRevisionName,status.traffic,metadata.annotations,metadata.labels,template.metadata.annotations,template.spec.containers)" | redact
echo

echo ">> Cloud Run revíziók listája"
gcloud run revisions list --service="$SERVICE" --region="$REGION" --project="$PROJECT"
LATEST_REV="$(gcloud run services describe "$SERVICE" --region="$REGION" --project="$PROJECT" --format='value(status.latestReadyRevisionName)' || true)"
if [[ -n "$LATEST_REV" ]]; then
  echo
  echo ">> Legutóbbi revízió describe: $LATEST_REV"
  gcloud run revisions describe "$LATEST_REV" --region="$REGION" --project="$PROJECT" --format="yaml" | redact
fi
echo

# ------ Scheduler ------
echo ">> Cloud Scheduler jobok"
gcloud scheduler jobs list --location="$REGION" --project="$PROJECT" || true
echo

# ------ Pub/Sub ------
echo ">> Pub/Sub topicok (szűrve a projektben)"
gcloud pubsub topics list --project="$PROJECT" || true
echo
echo ">> Pub/Sub subscription-ök a $TOPIC topicra (ha vannak)"
gcloud pubsub subscriptions list --project="$PROJECT" --filter="topic:projects/$PROJECT/topics/$TOPIC" || true
echo

# ------ Artifact Registry ------
echo ">> Artifact Registry repók (regionális)"
gcloud artifacts repositories list --location="$REGION" --project="$PROJECT" || true
echo

# ------ IAM kivonatok ------
echo ">> IAM - releváns szolgáltatásfiókok jogosultságai (kivonat)"
PUBSUB_SA="service-${PROJECT_NUMBER}@gcp-sa-pubsub.iam.gserviceaccount.com"
CB_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
FN_SA="$(gcloud functions describe "$FUNC" --region="$REGION" --gen2 --project="$PROJECT" --format='value(serviceConfig.serviceAccountEmail)' 2>/dev/null || true)"
echo "Pub/Sub managed SA:  $PUBSUB_SA"
echo "Cloud Build SA:      $CB_SA"
echo "Function SA:         ${FN_SA:-<ismeretlen>}"
echo
echo ">> Projekt IAM policy (szűrve a fenti fiókokra)"
gcloud projects get-iam-policy "$PROJECT" \
  --flatten="bindings[].members" \
  --format="table(bindings.role,bindings.members)" \
  | grep -E "$PROJECT_NUMBER|gcp-sa-pubsub|cloudbuild|$FN_SA" || true
echo

# ------ Build (Cloud Build) ------
echo ">> Legutóbbi Cloud Build build-ek (régió: $REGION)"
gcloud builds list --region="$REGION" --project="$PROJECT" --limit=10 || true
echo

# ------ Function logok (Gen2) ------
echo ">> Function logok (Gen2) – utolsó $EXTRA_LIMIT bejegyzés, kezdőidő: $CUTOFF (UTC)"
if command -v jq >/dev/null 2>&1; then
  gcloud functions logs read "$FUNC" --region="$REGION" --gen2 --project="$PROJECT" \
    --limit="$EXTRA_LIMIT" --start-time="$CUTOFF" --format="json" \
    | jq -r '.[] | [.severity, .timestamp, .executionId, (.message//.textPayload//.jsonPayload.message//"")] | @tsv'
else
  gcloud functions logs read "$FUNC" --region="$REGION" --gen2 --project="$PROJECT" \
    --limit="$EXTRA_LIMIT" --start-time="$CUTOFF"
fi
echo

# ------ Cloud Run request logok (CloudEvent fejlécek próbája) ------
echo ">> Cloud Run request logok – ce-* fejlécek (ha naplózott), kezdőidő: $CUTOFF (UTC)"
REQ_FILTER="resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"$SERVICE\""
if command -v jq >/dev/null 2>&1; then
  gcloud logging read "$REQ_FILTER AND timestamp>=\"$CUTOFF\"" \
    --project="$PROJECT" --limit="$EXTRA_LIMIT" --format="json" \
    | jq -r '
      .[] |
      {
        ts:(.timestamp//""), status:(.httpRequest.status//""), method:(.httpRequest.requestMethod//""),
        ce_id:(.jsonPayload.headers."ce-id"//""), ce_type:(.jsonPayload.headers."ce-type"//""),
        ce_source:(.jsonPayload.headers."ce-source"//"")
      } | @json'
else
  gcloud logging read "$REQ_FILTER AND timestamp>=\"$CUTOFF\"" \
    --project="$PROJECT" --limit="$EXTRA_LIMIT"
fi
echo

# ------ Hiba-detektorok (gyors következtetések) ------
echo ">> Gyors detektorok"
TR_LIST="$(gcloud eventarc triggers list --location="$REGION" --project="$PROJECT" --format='value(name,destination)' || true)"
echo "Trigger duplikáció-ellenőrzés:"
echo "$TR_LIST" | sed 's/^/  /'
if echo "$TR_LIST" | grep -qi "$SERVICE" && echo "$TR_LIST" | grep -qi "$FUNC"; then
  echo "MEGJEGYZÉS: Úgy tűnik, lehet egy Cloud Run és egy Cloud Functions trigger is. Ha igen, a régi CF triggert töröld."
fi
CE_MISSING=$(gcloud logging read "$REQ_FILTER AND timestamp>=\"$CUTOFF\"" --project="$PROJECT" --limit=10 --format="json" 2>/dev/null \
  | (command -v jq >/dev/null 2>&1 && jq -r '[.[].jsonPayload.headers."ce-id"] | any(.!=null) | not' || echo "unknown") )
if [[ "$CE_MISSING" == "true" ]]; then
  echo "MEGJEGYZÉS: Nem látszanak ce-* fejlécek a request logban -> valószínűleg nem CloudEventként hívódik a függvény."
fi
echo

# ------ Lokális repo ellenőrzések (ha elérhető a kód) ------
echo ">> Lokális kódellenőrzések (package.json, tsconfig, buildelt index) – ha léteznek"
for ROOT in "cloud_functions" "functions" "."; do
  if [[ -f "$ROOT/package.json" ]]; then
    echo "--- $ROOT/package.json kivonat:"
    grep -E '"name"|"main"|"type"|"scripts"|"firebase-functions"|"firebase-admin"' -n "$ROOT/package.json" || cat "$ROOT/package.json"
  fi
  if [[ -f "$ROOT/tsconfig.json" ]]; then
    echo "--- $ROOT/tsconfig.json kivonat:"
    grep -E '"outDir"|"include"|"exclude"|"module"|"target"|"skipLibCheck"' -n "$ROOT/tsconfig.json" || cat "$ROOT/tsconfig.json"
  fi
  if [[ -f "$ROOT/lib/index.js" ]]; then
    echo "--- $ROOT/lib/index.js export ellenőrzés (első 120 sor):"
    sed -n '1,120p' "$ROOT/lib/index.js"
    echo "--- keresés onMessagePublished / match_finalizer export mintákra:"
    grep -nE "onMessagePublished|exports\.match_finalizer|export const match_finalizer" "$ROOT/lib/index.js" || true
  fi
  if [[ -f "$ROOT/dist/index.js" ]]; then
    echo "--- $ROOT/dist/index.js export ellenőrzés (első 120 sor):"
    sed -n '1,120p' "$ROOT/dist/index.js"
    echo "--- keresés onMessagePublished / match_finalizer export mintákra:"
    grep -nE "onMessagePublished|exports\.match_finalizer|export const match_finalizer" "$ROOT/dist/index.js" || true
  fi
done
echo

# ------ Opcionális tesztüzenet publikálás ------
if [[ "$PUBLISH_TEST" == "true" ]]; then
  echo ">> Teszt Pub/Sub üzenet küldése a topics/$TOPIC témára"
  gcloud pubsub topics publish "projects/$PROJECT/topics/$TOPIC" \
    --message='{"job":"final-sweep","test":true}' --project="$PROJECT" || true
  echo "Várakozás 6s..."
  sleep 6
  echo ">> Friss function logok a teszt után (limit 50)"
  gcloud functions logs read "$FUNC" --region="$REGION" --gen2 --project="$PROJECT" \
    --limit=50 --start-time="$CUTOFF"
fi

echo
echo "=== DIAG VÉGE ==="
echo "Kimeneti teljes log: $OUT"
