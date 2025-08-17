version: "2025-08-17"
last_updated_by: codex-bot
depends_on: []

# H2H odds fetch fix

- Fixed API-Football `bet` parameter to use integer `1` for Match Winner market.
- Removed eager H2H odds loading from fixture list; card fetches odds on demand with 60s cache.
- Added guard and memory cache for `getH2HForFixture`.
- Event bet card now uses existing odds before hitting network.
- Odds URL assembled with `Uri` to avoid param collisions; added debug `X-Client` header.
- Implemented 200 ms backoff + one retry on HTTP 429.
- Cache now stores only non-null results; null responses are not cached.

