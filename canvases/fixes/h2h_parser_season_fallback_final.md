# H2H – végleges javítás: parser + season + fallback

## Probléma (összegzés)

* A runtime H2H a kártyán **season nélkül** kérte az oddsot.
* A `MarketMapping.h2hFromApi()` a régi (OddsAPI) sémát kereste (`json.markets`), míg az API‑Football válasz **`response → bookmakers → bets → values`**.
* Csak az első bookmaker/bet ágat néztük; ha ott nem volt 1X2/Match Winner, korán feladtuk.

## Megoldás

1. **Parser csere**: `h2hFromApi(json)` végigjárja az összes `bookmaker` és `bet` ágat, és a `Match Winner` / `1X2` / `Full Time Result` / `Match Result` / `Winner` aliasok egyikét keresi. A `values`‑ból a **Home/1**, **Draw/X**, **Away/2** értékeket normalizálja és átalakítja `OddsOutcome`‑okká.
2. **Season átadás**: `ApiFootballService.getH2HForFixture(int fixtureId, {int? season})`; a kártya FutureBuilderje átadja az `event.season`‑t.
3. **Kétlépcsős lekérés**: először `&bet=1X2` szűkítés, ha üres a `response`, **fallback** ugyanarra **bet nélkül**.
4. **Cache kulcs**: `"<fixtureId>-<season>"`, hogy szezonfüggő legyen.

## Elfogadási kritériumok

* [ ] A H2H (1/X/2) gombsor **minden** olyan kártyán megjelenik, ahol az API küld 1X2/Match Winner piacot.
* [ ] Az első kérés `bet=1X2`‑vel megy, üresnél fallback történik ugyanarra bet nélkül.
* [ ] `flutter analyze` és `flutter test` zöld.

## Érintett fájlok

* `lib/services/market_mapping.dart` – új H2H parser (API‑Football séma)
* `lib/services/api_football_service.dart` – season + fallback + cache kulcs
* `lib/widgets/event_bet_card.dart` – FutureBuilder season átadása
* (teszt) `test/services/market_mapping_h2h_parse_test.dart`, `test/services/api_football_service_odds_fallback_test.dart`

> A patch **nem tör** meglévő funkciót: kizárólag a H2H lekérés/parszolás útját javítja, a UI struktúráját nem érinti.
