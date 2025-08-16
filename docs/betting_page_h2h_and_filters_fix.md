# Betting page – H2H and filters fix

## Summary
- Correct Match Winner parameter: `&bet=1`.
- Fixture list only loads fixtures; cards fetch H2H with 60s in-memory cache.
- `getH2HForFixture` guards invalid ids and caches results.
- Service and cache respect the selected date (`fixtures?date=YYYY-MM-DD`), cache key: `sport|date|country|league`.
- Country/League dropdowns include an "Any" option (null value).
- H2H requests use a 10s timeout and a single retry.
- Added unit tests for URL building, fallback logic, and date filtering plus widget coverage.
