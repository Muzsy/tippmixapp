#!/usr/bin/env bash
set -euo pipefail

# Dev offline orchestrator:
# 1) Build functions
# 2) Start emulators (import state and export on exit)
# 3) Seed Firestore
# 4) Print next-step for Flutter run (user executes locally)

export USE_EMULATOR=true
export USE_MOCK_SCORES=true
export USE_INLINE_FINALIZER=true
export API_FOOTBALL_KEY=dummy

echo "[1/4] Building Cloud Functions..."
(cd cloud_functions && npm ci && npm run build)

echo "[2/4] Starting Firebase Emulators... (Ctrl+C to stop)"
mkdir -p .emulator_data
FIREBASE_EMULATOR_UI_PORT=4000 \
firebase emulators:start --only auth,firestore,storage,functions --import=.emulator_data --export-on-exit &
EMU_PID=$!
sleep 5

echo "[3/4] Seeding Firestore + Auth..."
npm run -s auth:seed || true
npm run -s seed

echo "[4/4] Ready. Emulator UI: http://localhost:4000"
echo "Run Flutter with: flutter run --dart-define=USE_EMULATOR=true"

wait $EMU_PID || true

