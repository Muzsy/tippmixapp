# Cloud Functions Cost Hardening – Report

## Changes
- global.ts:
  - Removed global `minInstances` (default 0).
  - `memory`: 1GiB → 512MiB.
  - `concurrency`: 15 → 10.
  - `maxInstances`: 30 → 10.
- index.ts:
  - Disabled mass daily cron export: `daily_bonus` commented out (keep `claim_daily_bonus`).
  - Pub/Sub wrapper logs: `match_finalizer.no_message` and `match_finalizer.done` → DEBUG.
- src/daily_bonus.ts:
  - Removed per-page progress log to reduce volume.
- coin_trx.logic.ts:
  - Success log `coin_trx.success` → DEBUG.
- src/match_finalizer.ts:
  - `match_finalizer.no_pending_fixture` → DEBUG (noise reduction).
- src/username_reservation.ts:
  - Success log `reserve_nickname.ok` → DEBUG.
- src/finalize_publish.ts:
  - Success log `finalize_publish.published` → DEBUG.
- package.json (cloud_functions):
  - Test script runs under Firestore Emulator wrapper to keep rules tests green: `firebase emulators:exec --only firestore "jest"`.

## Expected impact
- Gen2 scaling: `minInstances=0`, `1GiB→512MiB`, smaller concurrency/maxInstances → ~20–40% cost reduction (cold starts acceptable for dev/prod non-critical paths).
- Logging: INFO→DEBUG on frequent success/flow logs and page log removal → ~30–50% logging volume reduction (with Log Router excludes/short retention this compounds further).
- Daily mass cron disabled: removes fixed daily compute + logs. User-initiated `claim_daily_bonus` remains available.

## Build & tests
- TypeScript build: PASS (`tsc`).
- Jest: PASS under Firestore Emulator wrapper (rules tests require emulator). Other suites unchanged.

Command summary:
- Build: `pnpm build`
- Tests: `pnpm test` (wraps with `firebase emulators:exec --only firestore`)
- Type check: `npx tsc -p tsconfig.json --noEmit`

## Notes
- No business logic changed; only scaling options and log levels adjusted.
- ERROR/WARN logs retained as-is.
- Re-enabling mass cron later only requires uncommenting its export in `index.ts`.
