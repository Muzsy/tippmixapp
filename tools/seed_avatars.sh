#!/usr/bin/env bash
set -euo pipefail

HOST="${FIREBASE_STORAGE_EMULATOR_HOST:-localhost:9199}"
PROJECT="${GOOGLE_CLOUD_PROJECT:-tippmixapp-dev}"
BUCKET="${FIREBASE_STORAGE_BUCKET:-$PROJECT.appspot.com}"

echo "Uploading placeholder avatar to Storage emulator bucket: $BUCKET"

# Use repo's placeholder file (0 bytes) as a sample object
FILE_PATH="assets/avatar/.gitkeep"
OBJECT_NAME="avatars/default.txt"

curl -s -X POST "http://$HOST/v0/b/$BUCKET/o?name=$OBJECT_NAME" \
  -H "Content-Type: text/plain" \
  --data-binary @"$FILE_PATH" >/dev/null

echo "Done. Object path: gs://$BUCKET/$OBJECT_NAME"

