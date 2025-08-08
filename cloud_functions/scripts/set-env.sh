#!/bin/bash
# Használat: ./scripts/set-env.sh env.settings.dev > /tmp/env.vars

set -e

if [ -z "$1" ]; then
  echo "Használat: $0 <env.settings fájl>"
  exit 1
fi

ENV_FILE="$1"

if [ ! -f "$ENV_FILE" ]; then
  echo "Hiba: nincs ilyen fájl: $ENV_FILE"
  exit 2
fi

while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" =~ ^# ]] && continue

  key=$(echo "$key" | xargs)
  value=$(echo "$value" | xargs)

  # Idézőjelekbe tesszük az értéket, escape-elve
  echo "${key}=\"${value}\""
done < "$ENV_FILE"
