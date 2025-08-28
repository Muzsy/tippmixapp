#!/usr/bin/env bash
# Deploys match_finalizer and runs a Pub/Sub smoke test, ensuring no
# "TypeError: Cannot read properties of undefined (reading 'messageId')" appears.
# If the error is detected, performs an automatic clean rebuild and redeploy,
# then retries the smoke test until success or max attempts.

set -euo pipefail

# Params (overridable via env)
PROJECT_ID="${PROJECT_ID:-tippmix-dev}"
REGION="${REGION:-europe-central2}"
FUNCTION_NAME="${FUNCTION_NAME:-match_finalizer}"
RUN_SERVICE_NAME="${RUN_SERVICE_NAME:-match-finalizer}"
TOPIC="${TOPIC:-projects/${PROJECT_ID}/topics/result-check}"
SERVICE_ACCOUNT="${SERVICE_ACCOUNT:-}"
DEPLOYER="${DEPLOYER:-firebase}"   # firebase | gcloud
# Secret Manager binding (for gcloud deploy). Default to project-level secret latest version.
SECRET_API_FOOTBALL_KEY="${SECRET_API_FOOTBALL_KEY:-projects/${PROJECT_ID}/secrets/API_FOOTBALL_KEY:latest}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-3}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CF_DIR="${ROOT_DIR}/cloud_functions"

log() { echo "[$(date '+%H:%M:%S')] $*"; }

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing binary: $1"; exit 2; }
}

require node
require npm
require gcloud

attempt=1
while (( attempt <= MAX_ATTEMPTS )); do
  log "Attempt ${attempt}/${MAX_ATTEMPTS}: build → deploy → smoke-test"

  # Build CF (clean on retries)
  pushd "$CF_DIR" >/dev/null
  if (( attempt > 1 )); then
    log "Cleaning node_modules and lockfile (cloud_functions)"
    rm -rf node_modules package-lock.json || true
  fi
  log "Installing deps (cloud_functions)"
  npm ci
  log "Building (tsc)"
  npm run -s build
  popd >/dev/null

  # Deploy using selected deployer
  if [[ "$DEPLOYER" == "firebase" ]]; then
    log "Deploying (firebase) function ${FUNCTION_NAME} (project=${PROJECT_ID})"
    npx --yes firebase deploy --only "functions:${FUNCTION_NAME}" --project "${PROJECT_ID}" --force
  elif [[ "$DEPLOYER" == "gcloud" ]]; then
    log "Deploying (gcloud) function ${FUNCTION_NAME} (project=${PROJECT_ID})"
    pushd "$CF_DIR" >/dev/null
    TOPIC_SHORT="${TOPIC##*/}"
    ARGS=(functions deploy "${FUNCTION_NAME}" --gen2 --runtime=nodejs20 --region="${REGION}" \
          --entry-point="${FUNCTION_NAME}" --trigger-topic="${TOPIC_SHORT}" --source="." \
          --set-secrets="API_FOOTBALL_KEY=${SECRET_API_FOOTBALL_KEY}")
    if [[ -n "${SERVICE_ACCOUNT}" ]]; then
      ARGS+=(--service-account="${SERVICE_ACCOUNT}")
    fi
    gcloud "${ARGS[@]}"
    popd >/dev/null
  else
    log "Unknown DEPLOYER='${DEPLOYER}'. Use 'firebase' or 'gcloud'."
    exit 2
  fi

  # Run smoke via existing diagnostic helper (publishes Pub/Sub and reads logs)
  pushd "$ROOT_DIR" >/dev/null
  log "Running delivery diagnostic + smoke publish"
  PROJECT_ID="${PROJECT_ID}" REGION="${REGION}" FUNCTION_NAME="${FUNCTION_NAME}" RUN_SERVICE_NAME="${RUN_SERVICE_NAME}" TOPIC="${TOPIC}" LOG_AFTER_PUBLISH_SECONDS=12 LOG_LIMIT=120 \
    bash scripts/check_eventarc_pubsub_delivery.sh || true

  # Find the last diag log file
  LOGFILE="$(ls -1t diag_eventarc_pubsub_${PROJECT_ID}_${REGION}_${RUN_SERVICE_NAME}_*.log 2>/dev/null | head -n1 || true)"
  if [[ -z "$LOGFILE" ]]; then
    log "No diag logfile found. Treating as failure."
    ((attempt++))
    continue
  fi

  log "Analyzing logs: $LOGFILE"
  # Restrict analysis to the latest deployed revision to avoid tripping on older errors
  CURRENT_REV="$(gcloud functions describe "${FUNCTION_NAME}" --gen2 --region="${REGION}" --format='value(serviceConfig.revision)' || true)"
  if [[ -z "$CURRENT_REV" ]]; then
    log "Could not determine current revision; scanning entire logfile."
    REV_FILTER_CMD="cat"
  else
    REV_FILTER_CMD="grep -F \"${CURRENT_REV}\""
    log "Filtering Cloud Run logs by revision: ${CURRENT_REV}"
  fi
  if $REV_FILTER_CMD "$LOGFILE" | grep -q "TypeError: Cannot read properties of undefined (reading 'messageId')"; then
    log "Detected 'messageId' TypeError in logs. Applying auto-fix and retrying…"
    # Auto-fix strategy: ensure fresh install + rebuild on next loop (done above), then redeploy.
    # Code already uses v2 CloudEvent signature (onMessagePublished) with proper guards.
    ((attempt++))
    popd >/dev/null || true
    continue
  fi

  log "Success: No 'messageId' TypeError found in logs."
  echo
  echo "==== SUMMARY ===="
  echo "Project:      ${PROJECT_ID}"
  echo "Region:       ${REGION}"
  echo "Function:     ${FUNCTION_NAME}"
  echo "Topic:        ${TOPIC}"
  echo "Attempts:     ${attempt}"
  echo "Diag logfile: ${LOGFILE}"
  exit 0
done

log "Failed after ${MAX_ATTEMPTS} attempts. 'messageId' TypeError persisted."
exit 1
