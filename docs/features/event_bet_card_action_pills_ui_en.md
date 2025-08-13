# 🃏 Event Bet Card Action Pills UI (EN)

Replaces the bottom action buttons on `EventBetCard` with a unified pill-style row using the reusable `ActionPill` widget.

## Summary

- Introduces `ActionPill` widget for icon + label buttons.
- `EventBetCard` renders three `ActionPill`s separated by a `Divider`.
- Callbacks `onMoreBets`, `onStats`, and `onAi` wired to the pills.

## Testing

- `flutter analyze`
- `flutter test`
