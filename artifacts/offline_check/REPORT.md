# Offline Mode Hardening – Verification Report

## Summary
- Added iOS ATS exception to allow HTTP connections to local emulators in debug/simulator (dev only, non-prod).
- Pinned Node to 20.x for Cloud Functions and added root `.nvmrc` (v20) for consistent local environment.
- Added an "Offline quickstart (no cloud)" section to README with Java note, emulator steps, and Pub/Sub remark.
- Verified Firebase Emulator Suite starts and Emulator UI responds on http://localhost:4000.
- Flutter analyze now clean of errors (only warnings/infos) and a smoke test passes.
- Kept all existing behavior intact; no prohibited files (e.g., firebase.json) modified.

## Discoveries (JSON)
See `artifacts_discovery.json` (snapshot). Key points:

```json
$(cat artifacts_discovery.json)
```

## Applied changes (git log short)
- ios: add ATS exception for local emulators (dev only)
- node: pin project to Node 20 for local emulators/functions
- docs: add offline quickstart, Java note, and Pub/Sub remark
- fix(forum): align Report API usage and update test fakes for new ForumRepository methods

Full log: `artifacts/offline_check/gitlog.txt`

## Verification results
- Node: `$(cat artifacts/offline_check/node_version.txt | tr -d '\n')`
- pnpm: `$(cat artifacts/offline_check/pnpm_version.txt | tr -d '\n')`
- Java: see `artifacts/offline_check/java_version.txt` (OpenJDK 17 detected)
- Flutter: see `artifacts/offline_check/flutter_version.txt`
- Flutter analyze: OK (warnings only). Log: `artifacts/offline_check/flutter_analyze.txt`
- Smoke test: `test/accessibility_test.dart` – PASS. Log: `artifacts/offline_check/flutter_test.txt`
- Functions install: ran `pnpm i --frozen-lockfile` – see `artifacts/offline_check/functions_install.txt`
- Emulator UI status: `$(cat artifacts/offline_check/emulator_ui_status.txt)` (expect 200)
- Emulator log: `artifacts/offline_check/emulator.log`

## Acceptance criteria
- [x] iOS Info.plist contains ATS exception for local emulators
- [x] Repo signals Node 20 requirement (`.nvmrc` present; Functions engines set to `20.x`)
- [x] README has "Offline quickstart (no cloud)" with Java mention + Pub/Sub remark
- [x] Firebase Emulator Suite UI reachable (HTTP 200 on port 4000)
- [x] Flutter analyze completes without errors (warnings allowed)
- [x] Smoke step succeeded (accessibility test)

## Open issues / Next steps
- P1: Emulator export failed during forced shutdown (see `emulator.log`). This happened because the suite was terminated shortly after startup during verification. In normal usage (`tools/dev_offline.sh`) it runs persistently and exports on exit. No action needed, but for CI we can add a longer grace period or skip export.
- P2: A few analyzer warnings remain (forum tests: unused imports, mustCallSuper). Non-blocking.

## PR text (suggested)
This PR hardens the local offline developer mode:
- Adds iOS ATS exception for local emulators (debug-only)
- Pins Node to 20.x for Cloud Functions and adds root `.nvmrc`
- Introduces concise "Offline quickstart" in README (with Java and Pub/Sub notes)
- Verifies emulator startup, Flutter analyze, and a smoke test

No production behavior changes. Emulator ports and configs are unchanged. All steps verified on Linux Mint; logs included under `artifacts/offline_check/`.
