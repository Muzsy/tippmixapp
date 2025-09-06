#!/usr/bin/env bash
set -euo pipefail

# Guard against committing hard-coded prod endpoints in dev code
echo "Running precommit guard..."

bad=$(rg -n "https?://[a-z0-9.-]*europe-[a-z0-9-]+2[^"]*" lib cloud_functions || true)
if [[ -n "$bad" ]];
then
  echo "Found suspicious cloud endpoints in source files:" >&2
  echo "$bad" >&2
  exit 1
fi

echo "Precommit guard passed."

