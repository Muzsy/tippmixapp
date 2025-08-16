# H2H – Runtime javítás a tényleges repó állapotára

## Mit találtam a zip kibontása után

* **`EventBetCard`** a H2H‑t **újra lekéri**: `apiService.getH2HForFixture(int.tryParse(event.id) ?? 0)` – **season nélkül**.
* **`ApiFootballService.getH2HForFixture`** a belső `_fetchH2HForFixture`‑t hívja, ami **`getOddsForFixture(fixtureId.toString())`** – szintén **season nélkül**.
* **`MarketMapping.h2hFromApi`** még a **régi (OddsAPI)** sémát várja (`json['markets']`), ezért **mindig `null`**‑t ad az API‑Football válaszra.
* A service viszont a fixtures dúsításakor már **helyesen** parszol: `_parseH2HBookmakers(response→bookmakers→bets→values)` és **átadja a `season`‑t** – de ezt a kártya **nem** használja, mert újrahívja a service‑t.

## Következmény

A kártya FutureBuilderje olyan H2H‑t kér le, amit a service **season nélkül** és **hibás parserrel** olvas → `null` → „Nincs elérhető piac”.

## Javítás célja

* A runtime H2H‑hívás **season**‑nel menjen.
* A parser a **`response→bookmakers→bets→values`** útvonalat használja.
* Opcionális: fallback teljes odds lekérésre, ha a `bet=1X2` üres.

## Változások (nem törik a meglévő funkciót)

1. `lib/services/market_mapping.dart` – **új H2H parser** API‑Football sémára, `OddsOutcome`‑okkal.
2. `lib/services/api_football_service.dart`

   * `getH2HForFixture(int fixtureId, {int? season})` + cache kulcs `"<id>-<season>"`.
   * `_fetchH2HForFixture(int fixtureId, {int? season})` → először `bet=1X2`, ha üres, fallback **bet nélkül**.
   * `getOddsForFixtureAll(...)` új segédfüggvény (bet nélküli URL).
3. `lib/widgets/event_bet_card.dart` – a FutureBuilder **átadja a `event.season`**‑t a service‑nek.

## Elfogadási kritériumok

* [ ] A kártyákon megjelenik az 1/X/2 gombsor, ahol az API ad piacot.
* [ ] A service első körben `bet=1X2`‑vel kér, üresnél fallback **bet nélkül**.
* [ ] `flutter analyze` / `flutter test` zöld marad.

> Megjegyzés: az enrich‑elt `event.bookmakers` elsődleges használata további optimalizáció lenne (kevesebb hálózati hívás), de most a hibát a season+parser oldalon javítjuk, hogy a jelenlegi FutureBuilder is működjön.
