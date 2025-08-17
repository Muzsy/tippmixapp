version: "2025-08-31"
last_updated_by: codex-bot
depends_on: []

# Odds request hardening

- Added `bookmaker` query with default ID to reduce `/odds` response size.
- Logged odds HTTP status code in assert mode for easier diagnostics.
- Event bet card extracts numeric fixture ID with regex fallback.
- Season parameter falls back to event year when missing.
