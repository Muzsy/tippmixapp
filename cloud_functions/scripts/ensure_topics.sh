#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   PROJECT_ID=${PROJECT_ID:-tippmix-dev} ./scripts/ensure_topics.sh result-check result-check-dlq

PROJECT_ID=${PROJECT_ID:-tippmix-dev}

create_topic() {
  local topic="$1"
  gcloud pubsub topics describe "$topic" --project "$PROJECT_ID" >/dev/null 2>&1 || \
  gcloud pubsub topics create "$topic" --project "$PROJECT_ID"
}

for t in "$@"; do
  create_topic "$t"
  echo "Topic ensured: $t"
done

