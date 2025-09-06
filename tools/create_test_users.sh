#!/usr/bin/env bash
set -euo pipefail

HOST="${FIREBASE_AUTH_EMULATOR_HOST:-localhost:9099}"
BASE="http://$HOST/identitytoolkit.googleapis.com/v1"
KEY="fake-api-key"

create_user() {
  local email="$1"; shift
  local password="$1"; shift
  curl -s -X POST "$BASE/accounts:signUp?key=$KEY" \
    -H 'Content-Type: application/json' \
    -d "{\"email\":\"$email\",\"password\":\"$password\",\"returnSecureToken\":true}" >/dev/null
  echo "Created $email"
}

echo "Creating Auth emulator users..."
create_user user@example.com Passw0rd!
create_user moderator@example.com Passw0rd!
create_user admin@example.com Passw0rd!
echo "Done."

