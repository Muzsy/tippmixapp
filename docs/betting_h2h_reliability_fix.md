version: "2025-08-17"
last_updated_by: codex-bot
depends_on: []

# Betting H2H reliability fix

- `getH2HForFixture` caches only successful non-null results; empty responses and errors are not stored.
- `getOddsForFixture` retries once after a 429 status with a 200 ms delay and surfaces the error to callers.
- In debug builds an `X-Client: tippmixapp-mobile` header is added and outgoing `/odds` URLs are logged.
- Odds endpoint URL built via `Uri.replace` to prevent query concatenation bugs.
