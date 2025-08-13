# Backend: OddsAPI → API-Football cutover (Cloud Functions)

**Dátum:** 2025-08-12

**Változás lényege:**
- `match_finalizer` mostantól az `ApiFootballResultProvider`-t használja.
- A régi `ResultProvider.ts` és az OddsAPI mock ( `mock_scores/oddsApiSample.json` ) törölve.

**Követelmények:**
- `API_FOOTBALL_KEY` beállítva Functions környezetben.

**Ellenőrzés:**
- `npm run build` + `npm test` zöld a `cloud_functions` alatt.
- Logokban nincs örökölt OddsAPI hivatkozás a src-ből.
