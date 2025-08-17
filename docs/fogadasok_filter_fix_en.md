version: "2025-08-17"
last_updated_by: codex-bot
depends_on: []

# Bets filter network simplification

- Filter bar stays visible even when no events are available.
- Odds are refetched only when the date changes; country and league filters work client-side.
- Dropdowns in the filter bar use Wrap layout and expanded menus to avoid overflow.
- Cache key reduced to sport and date to prevent duplicate entries.
- Fixtures request omits country and league parameters; filtering happens locally.
