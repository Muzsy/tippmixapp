# 🏁 ApiFootballResultProvider Service (EN)

Adapter around API-Football fixtures endpoint. In production it performs live HTTP calls; in development when `USE_MOCK_SCORES=true` it reads JSON fixtures from `cloud_functions/mock_apifootball/`.

## Features
- Batch requests in groups of 40 event IDs.
- Falls back to local JSON when `MODE=dev` and mocking enabled.
- Throws on missing `API_FOOTBALL_KEY` or non-200 responses.
- Treats `FT/AET/PEN` statuses as completed and returns `winner` (home/away/draw).

## Testing
- Unit test covers mock mode with `fixtures_sample.json`.
