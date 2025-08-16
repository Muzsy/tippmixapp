# 🎚️ Esemény szűrősáv (HU)

Tapadós szűrősáv a Fogadások képernyő tetején, amellyel dátum, ország és liga szerint szűrhetünk.

## Összefoglaló

- Új `EventsFilter` modell és segédfüggvények.
- Újrahasznosítható `EventsFilterBar` widget.
- A `EventsScreen` tetején megjelenő sáv lokálisan szűri az eseménylistát.

## Tesztelés

- `flutter gen-l10n`
- `flutter analyze lib test integration_test bin tool`
- `flutter test --coverage`
