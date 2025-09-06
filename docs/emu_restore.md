# Emulator State Export/Restore

- Export current state: `pnpm run emu:export`
- Reset to clean state: `pnpm run emu:reset`
- Restore and start: `pnpm run emu:import`
- Seed after start: `pnpm run seed` and `pnpm run auth:seed`

Notes:
- Default ports: Auth 9099, Firestore 8080, Storage 9199, Functions 5001, UI 4000
- Client connects via `--dart-define=USE_EMULATOR=true`
