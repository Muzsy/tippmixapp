TippmixApp – Dependency hardening and test fixes (2025-08-28)

Summary
- Eliminated all npm audit vulnerabilities at repo root and in cloud_functions.
- Removed deprecated @firebase/testing and upgraded Firebase/Admin/Functions deps where safe.
- Fixed Firestore rules tests to match current rules spec and increased Mocha timeout.
- Performed clean installs to ensure reproducible environments.

Details
- Root
  - Ran npm audit fix → all 7 findings (1 critical) resolved.
  - Added devDependency @firebase/rules-unit-testing@^5.0.0 for rules tests.
  - Increased Mocha timeout in script test:rules:run to 15s to avoid emulator startup flakiness.
  - Clean install: removed node_modules and package-lock.json, regenerated lockfile, and ran npm ci.

- cloud_functions
  - Removed devDependency @firebase/testing (source of multiple vulnerabilities via request/node-fetch).
  - Upgraded deps: @google-cloud/pubsub 5.2.0, firebase-admin 13.5.0, firebase-functions 6.4.0.
  - Upgraded dev deps: firebase 12.2.0, firebase-tools 14.15.0.
  - Clean install: removed node_modules and package-lock.json, regenerated lockfile, and ran npm ci.
  - Jest tests pass (one duplicate mock warning due to compiled lib mock coexistence).

Tests
- cloud_functions: 4/4 test suites passed (1 skipped), 8/8 tests passed.
- Root Firestore rules (mocha + emulator): all 14 tests passing after updating test cases to align with rules.

Notes
- No changes were made to Flutter or Firebase configuration files (pubspec.yaml, firebase.json remain untouched).
- Consider a future, dedicated PR for major upgrades (e.g., Jest 30, NYC 17) to minimize risk.

