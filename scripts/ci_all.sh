#!/usr/bin/env bash
set -euo pipefail
./scripts/flutter_ci.sh
./scripts/mf_e2e.sh
