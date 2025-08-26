# 🏁 ApiFootballResultProvider Service (EN)

Adapter around API-Football fixtures endpoint. In production it performs live HTTP calls; in development when `USE_MOCK_SCORES=true` it reads JSON fixtures from `cloud_functions/mock_apifootball/`.

## Features
- Batch requests in groups of 40 event IDs.
- Falls back to local JSON when `MODE=dev` and mocking enabled.
- Throws on missing `API_FOOTBALL_KEY` or non-200 responses.
- Reads `API_FOOTBALL_KEY` from Secret Manager binding or environment variable; v1 `functions.config()` is no longer used.
- Treats `FT/AET/PEN` statuses as completed and returns `winner` (home/away/draw).
- Provides `findFixtureIdByMeta(eventName,startTime)` helper to resolve a `fixtureId` from team names and kickoff time when only metadata is available. It queries `GET /fixtures?date=YYYY-MM-DD&search=<team>` for both home and away names and returns the match with a case-insensitive name/date match.

## Testing
- Unit test covers mock mode with `fixtures_sample.json`.
- Unit test verifies `findFixtureIdByMeta` handling of malformed inputs.
