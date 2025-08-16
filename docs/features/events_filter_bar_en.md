# 🎚️ Events Filter Bar (EN)

Adds a sticky filter bar to the Bets screen allowing filtering by date, country and league.

## Summary

- Introduces `EventsFilter` model and utilities.
- Adds reusable `EventsFilterBar` widget.
- Integrates the filter bar atop `EventsScreen` for local list filtering.

## Testing

- `flutter gen-l10n`
- `flutter analyze lib test integration_test bin tool`
- `flutter test --coverage`
