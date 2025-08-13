# Emulator E2E – Ticket Flow (create → finalize → payout)

## Prerequisites
- Firebase Emulators: Firestore, Auth
- Functions: `ApiFootballResultProvider` mock enabled under Jest (`__mocks__` folder)

## Steps
1. Run `npm ci && npm test` inside `cloud_functions/` – executes the E2E jest test.
2. Run `flutter analyze && flutter test` at the repo root – widget and service tests.

## Expected Result
- Green E2E test: single payout, second finalizer run is a no-op.
