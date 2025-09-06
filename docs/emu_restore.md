# Emulator State Export/Restore

- Export current state: `npm run emu:export`
- Reset to clean state: `npm run emu:reset`
- Restore and start: `npm run emu:import`
- Seed after start: `npm run seed` and `npm run auth:seed`

Notes:
- Default ports: Auth 9099, Firestore 8080, Storage 9199, Functions 5001, UI 4000
- Client connects via `--dart-define=USE_EMULATOR=true`

