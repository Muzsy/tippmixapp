# Emulator E2E – Ticket Flow (create → finalize → payout)

## Prerequisites
- Firebase Emulators: Firestore, Auth
- Functions: `ApiFootballResultProvider` mock enabled under Jest (`__mocks__` folder)

## Steps
1. `npm ci && npm test` inside `cloud_functions/` – runs the E2E Jest test.
2. `flutter analyze && flutter test` at repo root – widget and service tests.

## Expected outcome
- Green E2E test: single payout, second finalizer run is a no-op.
