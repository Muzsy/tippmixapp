#!/usr/bin/env bash
set -euo pipefail

PROJECT="${PROJECT:-tippmix-dev}"   # TODO
TOPIC="${TOPIC:-result-check}"      # TODO

gcloud config set project "$PROJECT" >/dev/null

MSG=${1:-'{"matchId":"MANUAL-TEST"}'}
gcloud pubsub topics publish "$TOPIC" --message="$MSG" --attribute=source=manual,env=dev
