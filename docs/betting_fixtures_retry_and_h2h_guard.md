version: "2025-08-30"
last_updated_by: codex-bot
depends_on: []

# Betting fixtures retry and H2H guard

- Added single retry with 200 ms backoff for fixtures list request (`GET /fixtures?date=`).
- Added unit tests for retry logic and H2H guard (no network when `fixtureId <= 0`).
