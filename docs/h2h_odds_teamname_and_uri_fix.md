version: "2025-08-17"
last_updated_by: codex-bot
depends_on: []

# H2H odds team-name and URI fix

- Recognize team-name values in API-Football H2H markets via optional `homeName`/`awayName` parameters.
- Extended aliases with "home/away" to parse two-outcome markets.
- `EventBetCard` forwards `event.homeTeam` and `event.awayTeam` to the service.
- Odds request built with `Uri` to avoid parameter collisions.
- Added 200 ms backoff plus one retry on HTTP 429.
- H2H cache stores only successful results; null responses remove the cache entry.
