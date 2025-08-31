#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   PROJECT_ID=${PROJECT_ID:-tippmix-dev} \
#   LOCATION=${LOCATION:-europe-central2} \
#   TOPIC=${TOPIC:-result-check} \
#   ./scripts/create_scheduler.sh

PROJECT_ID=${PROJECT_ID:-tippmix-dev}
LOCATION=${LOCATION:-europe-central2}
TOPIC=${TOPIC:-result-check}
JOB_NAME=${JOB_NAME:-finalizer-kick}
SCHEDULE=${SCHEDULE:-"*/5 * * * *"}

gcloud scheduler jobs create pubsub "$JOB_NAME" \
  --project="$PROJECT_ID" \
  --location="$LOCATION" \
  --schedule="$SCHEDULE" \
  --topic="$TOPIC" \
  --message-body='{"type":"diag-check","ts":"auto"}' || \
gcloud scheduler jobs update pubsub "$JOB_NAME" \
  --project="$PROJECT_ID" \
  --location="$LOCATION" \
  --schedule="$SCHEDULE" \
  --topic="$TOPIC" \
  --message-body='{"type":"diag-check","ts":"auto"}'

echo "Scheduler job '$JOB_NAME' ensured in $LOCATION (project $PROJECT_ID)."

