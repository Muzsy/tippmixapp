# 🎴 Event Bet Card Layout Refactor (EN)

Refactors the `EventBetCard` widget to present match details and actions in a cleaner, more informative layout.

## Summary

- Country name aligned left, league name and logo aligned right.
- Home and away team names allow up to two lines next to badges.
- Kickoff row shows countdown on the left and formatted start time on the right.
- Head‑to‑head buttons use the shared `ActionPill` style.
- Updated timestamp displayed bottom‑right, using event or fallback fetch time.
- Card keyed by event ID for stable list rendering.

## Testing

- `flutter analyze --no-fatal-infos lib test integration_test bin tool`
- `flutter test`
