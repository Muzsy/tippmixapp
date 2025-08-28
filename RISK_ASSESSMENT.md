Risk Assessment – Node deps refresh (2025-08-28)

Scope
- cloud_functions: dependency updates (firebase-admin, firebase-functions, @google-cloud/pubsub), removal of @firebase/testing, dev tool bumps.
- repo root: added @firebase/rules-unit-testing for rules tests; increased mocha timeout; no production runtime code changed.

Risks
- API behavior changes:
  - firebase-admin 13.x and firebase-functions 6.x contain minor behavior changes; Cloud Functions code compiles and unit tests pass, but runtime differences may surface in GCP.
- Engine constraints:
  - cloud_functions declares engines.node = 20. Local env runs Node v22 (warning only). Ensure Cloud Functions runtime uses Node 20 to match engines.
- Test changes:
  - Rules tests were aligned to current rules. If CI relied on legacy coin_logs paths, expectations have changed accordingly.
- Tooling drift:
  - Jest remains on 29.x to avoid major upgrade churn; a later upgrade may be needed.

Mitigations
- Comprehensive tests: All unit/e2e/rules tests pass locally.
- Incremental upgrades only: avoided major version bumps for Jest/NYC.
- Clean install: lockfiles regenerated and npm ci used for deterministic installs.

Rollback Plan
1) Revert dependency changes and test edits:
   - git checkout HEAD~1 -- cloud_functions/package.json package.json test/security_rules.test.mjs CHANGES.md RISK_ASSESSMENT.md
   - Or: git revert <commit> (if committed).
2) Restore previous lock state:
   - Replace package-lock.json files from main or prior commit in both root and cloud_functions.
3) Clean reinstall:
   - In repo root and cloud_functions: rm -rf node_modules package-lock.json && npm ci (using the restored lockfiles).
4) Validate:
   - cloud_functions: npm test
   - root rules: npm run test:rules
5) If Cloud Functions already deployed with new deps:
   - Redeploy previous working version: firebase deploy --only functions --force with the prior commit checkout.

Post-Rollback Checks
- Verify no new audit findings: npm audit
- Run smoke tests against Firestore emulator and (if applicable) staging project.

