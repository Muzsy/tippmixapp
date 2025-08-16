version: "2025-08-16"
last_updated_by: codex-bot
depends_on: []

# H2H odds fetch fix

- Fixed API-Football `bet` parameter to use integer `1` for Match Winner market.
- Removed eager H2H odds loading from fixture list; card fetches odds on demand with 60s cache.
- Added guard and memory cache for `getH2HForFixture`.
- Event bet card now uses existing odds before hitting network.

