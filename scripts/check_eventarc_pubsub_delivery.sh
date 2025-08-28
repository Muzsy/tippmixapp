#!/usr/bin/env bash
# Purpose: End-to-end diagnosztika Eventarc→Pub/Sub→Cloud Functions (Gen2) kézbesítési láncra.
# - Ellenőrzi: aktív projekt, régió, topic, trigger, subscription, DLQ, IAM jogok (Run Invoker, Token Creator)
# - Tesztüzenetet publikál a megadott Pub/Sub topicra
# - Friss function logokat gyűjt a publikálás után
# - Minden eredményt időbélyeges logfájlba ment
#
# Követelmények: gcloud SDK (bejelentkezve), Cloud SDK komponensek engedélyezve; Linux/Mac bash környezet.
# Megjegyzés: Nem módosít semmit; csak olvas és naplóz. (Nincs automatikus jogpótlás.)

set -euo pipefail

# KEY=VALUE argumentumok parszolása (pl. ./script.sh PROJECT_ID=foo REGION=bar)
for arg in "$@"; do
  case "$arg" in
    *=*)
      export "$arg"
      ;;
  esac
done

# ==== KONFIG (env változókkal felülírható) ====
PROJECT_ID="${PROJECT_ID:-tippmix-dev}"
REGION="${REGION:-europe-central2}"
FUNCTION_NAME="${FUNCTION_NAME:-match_finalizer}"
RUN_SERVICE_NAME="${RUN_SERVICE_NAME:-match-finalizer}"   # Gen2 CF alatt a Cloud Run service neve
TOPIC="${TOPIC:-projects/${PROJECT_ID}/topics/result-check}"
TRIGGER_NAME="${TRIGGER_NAME:-}"  # ha üres, a script megpróbálja kideríteni
ATTRIBUTES="${ATTRIBUTES:-}"      # pl.: "source=diag,env=dev"
LOG_AFTER_PUBLISH_SECONDS="${LOG_AFTER_PUBLISH_SECONDS:-12}"
LOG_LIMIT="${LOG_LIMIT:-100}"

TS_UTC="$(date -u +%Y%m%dT%H%M%SZ)"
LOGFILE="diag_eventarc_pubsub_${PROJECT_ID}_${REGION}_${RUN_SERVICE_NAME}_${TS_UTC}.log"

# ==== Segédfüggvények ====
section() { echo -e "\n===== $* =====" | tee -a "$LOGFILE"; }
log()     { echo "$*" | tee -a "$LOGFILE"; }
run()     { echo "+ $*" | tee -a "$LOGFILE"; eval "$*" 2>&1 | tee -a "$LOGFILE"; }
hr()      { printf '%*s\n' 80 '' | tr ' ' '=' | tee -a "$LOGFILE"; }

# ==== Előkészítés ====
section "Diagnosztika indul" 
log "Dátum (helyi): $(date '+%Y-%m-%d %H:%M:%S %z')"
log "Dátum (UTC):   $(date -u '+%Y-%m-%d %H:%M:%SZ')"
log "Projekt: $PROJECT_ID | Régió: $REGION | CF Gen2: $FUNCTION_NAME | Run service: $RUN_SERVICE_NAME | Topic: $TOPIC"
hr

section "gcloud verzió és aktív beállítás" 
run "gcloud --version"
run "gcloud config get project"

# ==== Projekt szám, Eventarc SA, runtime SA ====
section "Projekt meta és service accountok"
PROJECT_NUMBER="$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')"
EVENTARC_SA="service-${PROJECT_NUMBER}@gcp-sa-eventarc.iam.gserviceaccount.com"
log "PROJECT_NUMBER: ${PROJECT_NUMBER}"
log "Eventarc service agent: ${EVENTARC_SA}"

RUNTIME_SA="$(gcloud functions describe "$FUNCTION_NAME" --gen2 --region="$REGION" --format='value(serviceConfig.serviceAccountEmail)' || true)"
if [[ -n "${RUNTIME_SA}" ]]; then
  log "Runtime service account: ${RUNTIME_SA}"
else
  log "Runtime service account: N/A (functions describe nem adott vissza értéket)"
fi
hr

# ==== Topic ellenőrzés ====
section "Pub/Sub topic ellenőrzés"
run "gcloud pubsub topics describe '${TOPIC}' --format=json || true"

# ==== Triggerek listázása és kiválasztása ====
section "Eventarc trigger(ek) ellenőrzése"
run "gcloud eventarc triggers list --location='${REGION}' --format='table(name,transport.pubsub.topic,serviceName,active)'"

if [[ -z "${TRIGGER_NAME}" ]]; then
  # megpróbáljuk a functionhoz tartozó triggert megtalálni
  TRIGGER_NAME="$(gcloud eventarc triggers list --location="${REGION}" \
    --format="value(name)" \
    --filter="serviceName:${RUN_SERVICE_NAME}")"
fi

if [[ -n "${TRIGGER_NAME}" ]]; then
  log "Használt trigger: ${TRIGGER_NAME}"
  run "gcloud eventarc triggers describe '${TRIGGER_NAME}' --location='${REGION}'"
else
  log "Nem találtam triggert a '${RUN_SERVICE_NAME}' szolgáltatáshoz. Ellenőrizd a név egyezést."
fi
hr

# ==== Subscription(ök) a topicon ====
section "Subscription(ök) a topichoz"
run "gcloud pubsub subscriptions list --format='table(name,topic,ackDeadlineSeconds,deadLetterPolicy.deadLetterTopic)' \
  --filter='topic:${TOPIC}'"

# Ha van DLQ, listázzuk ki külön
DLQ_SUBS=$(gcloud pubsub subscriptions list --filter="topic:${TOPIC}" --format="value(deadLetterPolicy.deadLetterTopic)" | sort -u | grep -v '^$' || true)
if [[ -n "$DLQ_SUBS" ]]; then
  section "DLQ topic(ok) részletei"
  while IFS= read -r dlq_topic; do
    log "DLQ topic: $dlq_topic"
    run "gcloud pubsub topics describe '$dlq_topic' --format=json || true"
  done <<< "$DLQ_SUBS"
fi
hr

# ==== IAM ellenőrzések ====
section "IAM ellenőrzések"
log "Run Invoker a Cloud Run szolgáltatáson (${RUN_SERVICE_NAME}) az Eventarc SA számára"
run "gcloud run services get-iam-policy '${RUN_SERVICE_NAME}' --region='${REGION}' --format='yaml' | sed -n '1,160p'"

if [[ -n "${RUNTIME_SA}" ]]; then
  log "Service Account Token Creator a runtime SA-n (${RUNTIME_SA}) az Eventarc SA számára"
  run "gcloud iam service-accounts get-iam-policy '${RUNTIME_SA}' --format='yaml' | sed -n '1,160p'"
else
  log "Kihagyva a Token Creator ellenőrzést (nincs runtime SA)."
fi
hr

# ==== Teszt üzenet publikálás ====
section "Teszt Pub/Sub üzenet publikálás"
UUID="$(uuidgen || cat /proc/sys/kernel/random/uuid)"
PAYLOAD="{\"type\":\"diag-check\",\"uuid\":\"${UUID}\",\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}"
ATTR_ARGS=()
if [[ -n "${ATTRIBUTES}" ]]; then
  # ATTRIBUTES formátum: key1=val1,key2=val2
  IFS=',' read -ra KV <<< "${ATTRIBUTES}"
  for kv in "${KV[@]}"; do
    ATTR_ARGS+=("--attribute=${kv}")
  done
fi
run "gcloud pubsub topics publish '${TOPIC}' --message='${PAYLOAD}' ${ATTR_ARGS[@]:-}"
log "Várakozás ${LOG_AFTER_PUBLISH_SECONDS}s…"
sleep "${LOG_AFTER_PUBLISH_SECONDS}"
hr

# ==== Friss function logok ====
section "Friss function logok (Gen2)"
# Megpróbáljuk a natív CF logs olvasót és a Cloud Run szintű naplózást is
run "gcloud functions logs read '${FUNCTION_NAME}' --gen2 --region='${REGION}' --limit='${LOG_LIMIT}' || true"

section "Cloud Run szolgáltatás logjai (szolgáltatás: ${RUN_SERVICE_NAME})"
# A Log Explorer lekérdezés paraméterezve: az utolsó 30 perc
QUERY="resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${RUN_SERVICE_NAME}\""
run "gcloud logging read \"${QUERY}\" --freshness=30m --limit='${LOG_LIMIT}' --format='value(timestamp,logName,resource.labels.revision_name,textPayload)' || true"
hr

# ==== Felhalmozott (nem kézbesített) üzenetek ====
section "Subscription backlogs (numUndeliveredMessages)"
SUBS_LIST=$(gcloud pubsub subscriptions list --filter="topic:${TOPIC}" --format="value(name)" || true)
for sub in $SUBS_LIST; do
  log "Subscription: $sub"
  run "gcloud pubsub subscriptions describe '$sub' --format='yaml' | sed -n '1,220p'"
  hr
done

section "Diagnosztika vége"
log "Kimeneti logfájl: ${LOGFILE}"

# Hasznos kilépőkód: ha idáig eljutottunk, a script sikerrel lefutott
exit 0
