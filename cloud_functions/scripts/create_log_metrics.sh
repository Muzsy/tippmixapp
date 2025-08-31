#!/usr/bin/env bash
set -euo pipefail

# Usage: PROJECT_ID=tippmix-dev ./scripts/create_log_metrics.sh
PROJECT_ID=${PROJECT_ID:-tippmix-dev}

create_metric() {
  local NAME="$1" DESC="$2" FILTER="$3"
  if gcloud logging metrics describe "$NAME" --project "$PROJECT_ID" >/dev/null 2>&1; then
    echo "Metric exists: $NAME"
  else
    gcloud logging metrics create "$NAME" \
      --description "$DESC" \
      --project "$PROJECT_ID" \
      --log-filter "$FILTER"
  fi
}

create_metric \
  "mf_finalize_done_fixture_count" \
  "Count of fixture-mode finalize completions" \
  "resource.type=cloud_run_revision AND jsonPayload.message=\"match_finalizer.finalize_done_fixture\""

create_metric \
  "mf_sent_to_dlq_count" \
  "Count of messages sent to DLQ" \
  "resource.type=cloud_run_revision AND jsonPayload.message=\"match_finalizer.sent_to_dlq\""

create_metric \
  "mf_handle_error_count" \
  "Count of finalizer errors" \
  "resource.type=cloud_run_revision AND jsonPayload.message=\"match_finalizer.handle_error\""

echo "Log-based metrics ensured."

