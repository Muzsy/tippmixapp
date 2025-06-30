# Firestore Security Rules CI Integration

This document describes the continuous integration step that verifies Firestore security rules.

The `ci.yaml` workflow installs Node.js, restores dependencies, then runs `scripts/test_firebase_rules.sh` which executes `npm run test:rules:coverage`. The command starts the Firestore emulator and runs the Mocha test suite under `test/security_rules.test.mjs`.

Test output is saved to `security_rules_test.log` and uploaded as a workflow artifact. Coverage results generate `coverage/security_rules_badge.svg` that surfaces in the README.

The workflow fails on any security rules violation, preventing merges until the tests pass.
