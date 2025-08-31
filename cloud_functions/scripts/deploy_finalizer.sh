#!/usr/bin/env bash
set -euo pipefail

# Prereq: firebase login; gcloud auth login; project set
# Usage: PROJECT_ID=tippmix-dev ./scripts/deploy_finalizer.sh

PROJECT_ID=${PROJECT_ID:-tippmix-dev}

pushd "$(dirname "$0")/.." >/dev/null
npm run build

# Ensure topics
PROJECT_ID="$PROJECT_ID" ./scripts/ensure_topics.sh result-check result-check-dlq

# Deploy all functions (Gen2 options picked up from global.ts)
firebase use "$PROJECT_ID" || firebase use --add "$PROJECT_ID"
firebase deploy --only functions

popd >/dev/null
echo "Deployed cloud functions to project $PROJECT_ID"

