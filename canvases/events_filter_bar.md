# Fogadások – felső szűrősáv (dátum / ország / liga)

## Cél

A Fogadások képernyő tetején egy **tapadós** (sticky) szűrősáv jelenjen meg, amelyen a felhasználó szűrhet:

* **Dátum** (egy nap)
* **Ország**
* **Liga** (ország függvényében)

A szűrők **azonnal alkalmazódnak** (nincs külön Alkalmaz gomb). A Liga listát az aktuálisan szűrt eseményekből töltjük, így nem kell új hálózati hívás.

## Nem‑cél

* Nincs backend API módosítás; első körben **lokális** szűrés az aktuálisan betöltött eseményeken. (Később bővíthető olyan opcióval, hogy dátumra kimenő kérés szűkítse a fixtures‑hívást.)
* Nem törjük a meglévő H2H/ActionPill, kártya, és i18n funkciókat.

## UX részletek

* A sáv a lista tetején, kártyák fölött helyezkedik el; a tetejére görgetve **látszik** marad (StickyHeader).
* Vezérlők:

  * **Dátum**: pill stílusú gomb; tappra `showDatePicker` (vagy Material 3 DatePicker), kiválasztás után azonnali szűrés. A formátum a meglévő „Kezdés: YYYY/MM/DD HH\:MM” logikával konzisztens (csak nap pontosságú).
  * **Ország**: `DropdownButtonFormField<String>` egyedi listával az aktuális események országai közül (ABC sorban). Alapérték: „Mind”.
  * **Liga**: `DropdownButtonFormField<String>`; csak az adott ország ligái (ABC), alapérték: „Mind”. Ha ország „Mind”, akkor minden liga választható.
* **Törlés**: bármely szűrőnél a „Mind” opció visszaállítja az eredeti listát. Dátumnál „Ma” gomb.

## Adatmodell

`EventsFilter` (immutable):

```dart
class EventsFilter {
  final DateTime? date;     // csak nap pontosság – local
  final String? country;    // pontos név vagy null = Mind
  final String? league;     // pontos név vagy null = Mind
}
```

Állapotkezelés: egyszerű `ValueNotifier<EventsFilter>` (vagy ha már Riverpod/Provider van, ahhoz igazodunk). A szűrés a képernyőn történik: a betöltött `List<OddsEvent>` → `List<OddsEvent>`.

## Implementáció

* Új widget: `EventsFilterBar` – felület és belső logika (legördülők + dátumválasztó).
* Új util: `applyEventsFilter(List<OddsEvent>, EventsFilter)`.
* `EventsScreen` módosítás: a filter bar beszúrása a lista fölé, és az `onChanged` visszahívásra a lista újraszámítása.

## i18n kulcsok (HU/EN/DE)

```
filters.title = Szűrők | Filters | Filter
filters.date = Dátum | Date | Datum
filters.country = Ország | Country | Land
filters.league = Liga | League | Liga
filters.any = Mind | Any | Alle
filters.today = Ma | Today | Heute
```

## Acceptance

* [ ] Szűrősáv megjelenik a Fogadások képernyő tetején.
* [ ] Dátum/Ország/Liga választása azonnal szűri a kártyalistát.
* [ ] Liga drop‑down tartalma országfüggő.
* [ ] „Mind”/„Ma” visszaállítja az eredeti listát.
* [ ] `flutter analyze` és `flutter test` zöld.

## Teszt

* Unit: `applyEventsFilter` – dátum, ország, liga kombinációk.
* Widget: filter bar render + `onChanged` hívódik dátum kiválasztásakor és drop‑down váltáskor.

## Érintett fájlok

* `lib/features/filters/events_filter.dart` (modell + util)
* `lib/widgets/events_filter_bar.dart` (UI)
* `lib/screens/events_screen.dart` (integráció)
* `lib/l10n/intl_*.arb` (kulcsok)
* `test/features/events_filter_test.dart`, `test/widgets/events_filter_bar_test.dart`
