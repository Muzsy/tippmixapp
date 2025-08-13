# Emulatoros E2E – Ticket Flow (create → finalize → payout)

## Előfeltételek
- Firebase Emulators: Firestore, Auth
- Functions: `ApiFootballResultProvider` mock engedélyezve Jest alatt (`__mocks__` mappa)

## Lépések
1. `npm ci && npm test` a `cloud_functions/` alatt – lefut az E2E jest.
2. `flutter analyze && flutter test` a repo gyökerében – widget és service tesztek.

## Elvárt kimenet
- Zöld E2E teszt: egyszeri payout, második finalizer futás no-op.
