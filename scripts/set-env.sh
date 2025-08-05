#!/usr/bin/env bash
# Usage: ./scripts/set-env.sh env.settings.dev
paste -sd ',' "$1" | tr ',' '\n' | xargs | tr ' ' ','
# outputs: KEY1=val1,KEY2=val2 ...
