#!/usr/bin/env bash
set -euo pipefail

# Usage: PROJECT_ID=tippmix-dev ./scripts/create_alerts.sh
PROJECT_ID=${PROJECT_ID:-tippmix-dev}
POLICY_FILE="config/alerts/dlq_policy.json"

pushd "$(dirname "$0")/.." >/dev/null

# Create alert policy (requires notification channels to be added manually or via gcloud)
gcloud alpha monitoring policies create \
  --project "$PROJECT_ID" \
  --policy-from-file "$POLICY_FILE" || true

echo "Alert policy (DLQ spike) ensured. Configure notificationChannels as needed."

popd >/dev/null

