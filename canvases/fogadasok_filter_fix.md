# 🎯 Funkció

A Fogadások képernyő szűrési funkciójának javítása: a szűrősáv mindig látható marad, a szűrés kliensoldalon fut (ország/liga), a hálózati lekérés csak dátumra történik. A szűrő UI elrendezése kis kijelzőn sem folyik túl, a stílus közelít a kártyagombokhoz.

# 🧠 Fejlesztési részletek

* **Állapotkezelés**: `oddsApiProvider` továbbra is API‑Footballt hív, de csak **sport + dátum** paraméterekkel. Ország/ligaváltás **nem** indít új fetch-et, a lista memoizált forráson, kliensoldalon szűrődik (`EventsFilter.apply`).
* **Mindig látható szűrősáv**: az eddigi korai `return` („Nincs esemény”) miatt eltűnt a sáv. Eltávolításra kerül a korai visszatérés, így üres lista esetén is megmarad a sáv.
* **UI/layout**: `Row` → `Wrap(spacing, runSpacing)` a FilterBarban; a `DropdownButtonFormField` sűrített és `isExpanded: true`, hogy ne legyen overflow. Kis kijelzőn új sorba törhet.
* **Cache kulcs**: a hálózati cache kulcsból kikerül `country|league`, így azonos payload nem tárolódik többször.
* **API‑Football lekérés**: a `country`/`league` queryk elhagyása (API‑Football `fixtures` endpoint csak dátum/leagueId‑re stabil; jelen implementáció nem biztosít leagueId‑t, ezért a szűrés kliensen marad).

**Érintett fájlok**

* `lib/screens/events_screen.dart`
* `lib/widgets/events_filter_bar.dart`
* `lib/providers/odds_api_provider.dart`
* `lib/services/odds_cache_wrapper.dart`
* `lib/services/api_football_service.dart`

# 🧪 Tesztállapot

* Widget teszt: a FilterBar **Empty** és **Data (üres szűrt)** állapotokban is látható.
* Integráció: dátumváltás → hálózati fetch; ország/liga váltás → **nem** fetch, csak kliensszűrés.
* `flutter analyze` tiszta.

# 🌍 Lokalizáció

* A „Nincs esemény” üzenet megmarad; opcionálisan kiegészíthető „Módosítsd a szűrőket” javaslattal (HU/EN/DE) későbbi lépésben.

# 📎 Kapcsolódások

* API‑Football integráció és market mapping (meglévő vásznak).
* Tickets flow és odds drift – változatlan.
