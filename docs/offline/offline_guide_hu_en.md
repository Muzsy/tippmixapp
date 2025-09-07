# Tipsterino Offline Fejlesztői Útmutató / Offline Development Guide

Dátum / Date: 2025-09-06

---

## HU — Áttekintés

Ez a dokumentum lépésről lépésre bemutatja, hogyan futtasd a Tipsterino‑t teljesen offline módban a Firebase Emulator Suite és lokális mockok segítségével. Nem szükséges internet vagy felhős erőforrás.

- Emulátor portok: Auth 9099, Firestore 8080, Storage 9199, Functions 5001, UI 4000
- Környezeti változók (dev): `USE_EMULATOR=true USE_MOCK_SCORES=true USE_INLINE_FINALIZER=true API_FOOTBALL_KEY=dummy`
- Egyparancsos indítás: `npm run dev:offline:full`

### Előfeltételek
- Node.js 18+ (ajánlott 20), npm
- Flutter SDK (stable), Java 17, Android SDK
- Firebase CLI (13+)

### Telepítés
- Gyökérben: `npm ci`
- Functions: a `tools/dev_offline.sh` elintézi a buildet (TypeScript → JS)

### Emulátorok indítása
- `npm run emu:start` — UI: http://localhost:4000
- Állapot export/import: `npm run emu:export` / `npm run emu:import`
- Reset: `npm run emu:reset`

### Seedelés
- Auth felhasználók: `npm run auth:seed` (user/moderator/admin)
- Firestore adatok: `npm run seed` (user, pending ticket, fixtures index, leaderboard)
- Storage mintafájl: `bash tools/seed_avatars.sh`

### Flutter kliens
- Futás: `flutter run --dart-define=USE_EMULATOR=true`
- Emulator kötés: Firestore/Auth/Functions/Storage lokális hostokra állítva (Android: `10.0.2.2`, más: `localhost`)
- Analytics: devben kikapcsolva
- Remote Config: offline módban nem fetch-el, determinisztikus defaultot használ
- Build Guard: PROD projekt azonnal leáll, ha `USE_EMULATOR=true`

### Finalizer / Pub/Sub (haladó)
- Inline mód: `USE_INLINE_FINALIZER=true` esetén a Callable azonnal futtatja a finalizert.
- Dev „Pub/Sub emu” végpontok:
  - `dev_publish_finalize` (onCall): `fixtureId` alapján finalize üzenet vagy inline futtatás
  - `dev_scheduler_kick` (onCall): `diag-check` üzenet vagy inline futtatás
- Ha GCloud Pub/Sub emulátort használsz: állítsd `PUBSUB_EMULATOR_HOST=localhost:8086`, majd futtasd a `gcloud beta emulators pubsub start`‑ot (opcionális).

### QA forgatókönyv
- Lásd: `docs/qa/qa_offline_run.md` és töltsd ki a `docs/qa/offline_parity_report.md` sablont.

### Hibaelhárítás
- Android cleartext engedélyezve (Manifest + network_security_config)
- Functions logok: Emulator UI
- Auth REST példa: `tools/create_test_users.sh`
- Precommit guard: távoli felhő végpontok ellenőrzése

---

## EN — Overview

This guide explains how to run Tipsterino fully offline using the Firebase Emulator Suite and local mocks. No internet or cloud resources required.

- Emulator ports: Auth 9099, Firestore 8080, Storage 9199, Functions 5001, UI 4000
- Dev env vars: `USE_EMULATOR=true USE_MOCK_SCORES=true USE_INLINE_FINALIZER=true API_FOOTBALL_KEY=dummy`
- One‑command start: `npm run dev:offline:full`

### Prerequisites
- Node.js 18+ (20 recommended), npm
- Flutter SDK (stable), Java 17, Android SDK
- Firebase CLI (13+)

### Setup
- At repo root: `npm ci`
- Functions build handled by `tools/dev_offline.sh`

### Start Emulators
- `npm run emu:start` — UI at http://localhost:4000
- Export/Import: `npm run emu:export` / `npm run emu:import`
- Reset: `npm run emu:reset`

### Seeding
- Auth users: `npm run auth:seed` (user/moderator/admin)
- Firestore data: `npm run seed` (user, pending ticket, fixtures index, leaderboard)
- Storage sample file: `bash tools/seed_avatars.sh`

### Flutter Client
- Run: `flutter run --dart-define=USE_EMULATOR=true`
- Emulator binding: Firestore/Auth/Functions/Storage to local hosts (Android: `10.0.2.2`, others: `localhost`)
- Analytics: disabled in dev
- Remote Config: no fetch in offline mode, deterministic defaults
- Build Guard: aborts if PROD project with `USE_EMULATOR=true`

### Finalizer / Pub/Sub (advanced)
- Inline mode: with `USE_INLINE_FINALIZER=true`, the callable runs finalizer immediately.
- Dev "Pub/Sub emu" endpoints:
  - `dev_publish_finalize` (onCall): publish finalize or run inline by `fixtureId`
  - `dev_scheduler_kick` (onCall): publish diag‑check or run inline
- If using the GCloud Pub/Sub emulator: set `PUBSUB_EMULATOR_HOST=localhost:8086` and run `gcloud beta emulators pubsub start` (optional).

### QA Scenario
- See `docs/qa/qa_offline_run.md` and fill in `docs/qa/offline_parity_report.md` after the run.

### Troubleshooting
- Android cleartext enabled (Manifest + network_security_config)
- Functions logs: Emulator UI
- Auth REST examples: `tools/create_test_users.sh`
- Precommit guard: checks for cloud endpoints

---

## Parancsok / Commands

- Start full offline: `npm run dev:offline:full`
- Emulators: `npm run emu:start` | Reset: `npm run emu:reset` | Export: `npm run emu:export`
- Seed: `npm run auth:seed` && `npm run seed` && `bash tools/seed_avatars.sh`
- Flutter: `flutter run --dart-define=USE_EMULATOR=true`
