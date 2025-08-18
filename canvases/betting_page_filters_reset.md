# Fogadási oldal – Szűrők resetelése és Dropdown hiba javítása

## 🎯 Funkció

Dátum- és országváltáskor ne maradjon érvénytelen ligaválasztás. A cél, hogy:

* **Dátum váltásakor**: `country` és `league` visszaáll **"mind"** (null) állapotba.
* **Ország váltásakor**: `league` visszaáll **"mind"** (null) állapotba.
* A ligaválasztó `DropdownButtonFormField` **sose kapjon olyan `value`-t**, ami nincs az `items` között (különben assert piros hibát dob – lásd screenshot).

## 🧠 Fejlesztési részletek

Érintett fájl: `lib/widgets/events_filter_bar.dart`

Módosítások:

1. **Értékek érvényesítése render előtt**: ha a jelenlegi `f.country`/`f.league` nincs benne a listában (`countries`/`leagues`), akkor a vezérlőknek **`null` értéket** adunk át (`countryValue`, `leagueValue`).
2. **Reset logika**:

   * Dátum onChanged: `f.copyWith(date: d, country: null, league: null)` + `onChanged(f)`.
   * Ország onChanged: `f.copyWith(country: vOrNull, league: null)` + `onChanged(f)`.
3. **Leagues lista** továbbra is az aktuális `country` alapján készül, a kezdő elem `""` ("mind").

## 🧪 Tesztállapot

* Widget teszt: ország → liga → **másik ország** → **nincs kiválasztott liga**, nincs assert.
* Widget teszt: **dátum váltás** → ország és liga resetelt, **nincs kiválasztott liga**.
* Golden/snapshot: szűrősáv megjelenítés alapállapotban.

## 🌍 Lokalizáció

* Nincs új kulcs. A "mind" (üres string) megjelenítése továbbra is `AppLocalizations.filtersAny`.

## 📎 Kapcsolódások

* Kapcsolódik: `lib/features/filters/events_filter.dart` (countriesOf/leaguesOf), `lib/models/odds_event.dart` (forráslista).
* Szabályok: **Codex Canvas Yaml Guide.pdf** szerint készülő YAML diff.
