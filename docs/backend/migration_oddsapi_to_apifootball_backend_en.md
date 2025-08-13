# Backend: OddsAPI → API-Football cutover (Cloud Functions)

**Date:** 2025-08-12

**Summary of change:**
- `match_finalizer` now uses the `ApiFootballResultProvider`.
- Old `ResultProvider.ts` and the OddsAPI mock (`mock_scores/oddsApiSample.json`) removed.

**Requirements:**
- `API_FOOTBALL_KEY` configured in the Functions environment.

**Verification:**
- `npm run build` + `npm test` green under `cloud_functions`.
- No legacy OddsAPI references in source logs.
