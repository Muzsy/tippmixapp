# 🏁 ResultProvider Service (EN)

Adapter around OddsAPI /scores endpoint. In production it performs live HTTP calls; in development when `USE_MOCK_SCORES=true` it reads JSON fixtures from `functions/mock_scores/`.

## Features
- Batch requests in groups of 40 event IDs.
- Falls back to local JSON when `MODE=dev` and mocking enabled.
- Throws on missing `ODDS_API_KEY` or non-200 responses.

## Testing
- Unit test covers mock mode with `oddsApiSample.json`.
