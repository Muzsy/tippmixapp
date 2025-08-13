# API‑Football piacok betöltése + liga/ország fejléc a kártyán (P0)

🎯 **Funkció**

* A **H2H (1X2)** piac jelenjen meg minden eseménykártyán (1, X, 2 gombok), hogy lehessen fogadni.
* A kártya felső sávjában a sport helyett/ mellett jelenjen meg: **Ország • Liga** (pl. *Argentina • Liga Profesional*).

🧠 **Fejlesztési részletek**

* `ApiFootballService.getOdds(...)` jelenleg a `/fixtures` végpontot hívja, és **üres** `bookmakers` listát ad vissza → emiatt a `h2hMarket == null`.
* Javítás: álljunk át a **`/odds`** végpontra napi szűréssel (`date=YYYY-MM-DD`).
* **Transzformáció** API‑Football → belső modellek:

  * `response[].fixture` → `OddsEvent`: `id`, `commenceTime`; **új mezők**: `countryName`, `leagueName` a `league` ágból.
  * `bookmakers[].bets[]` → `OddsBookmaker.markets[]`

    * `bet.name` → `OddsMarket.key`: *Match Winner* → `h2h` (csak ez kell most)
    * `values[]` → `OddsOutcome` lista, ahol a *Home/Away* labelt **a csapatnevekre** képezzük le (`homeTeam`/`awayTeam`), a *Draw* változat `Draw` marad.
    * `odd` → `price` (double).
* Modellbővítés: `OddsEvent` kap két mezőt: `countryName`, `leagueName`; bekerül a (de)serialize‑be.
* UI: `EventBetCard` felső sorában a `event.sportTitle` helyett „`country • league`” látszik (ha nincs adat, marad sport).
* **Visszafelé kompatibilitás**: a meglévő hívók (cache, provider) változatlanul használhatók.

🧪 **Tesztállapot**

* Unit: transformer függvények (bet → market, values → outcomes) és az `OddsEvent` (de)serialize.
* Widget: kártya fejléc fallback (ha nincs league/country).
* Integráció: a `EventsScreen` lista 1X2 gombjai ténylegesen láthatók és kattinthatók.

🌍 **Lokalizáció**

* A „Ország • Liga” nem igényel új kulcsot; sima szöveg. A kezdési idő meglévő lokalizált sablont használ.

📎 **Kapcsolódások**

* `lib/services/api_football_service.dart`
* `lib/models/odds_event.dart` (+ serializer)
* `lib/widgets/event_bet_card.dart`
* `lib/screens/events_screen.dart` (nincs módosítás, csak ellenőrzés)

**Elfogadási kritériumok**

* [ ] A *Fogadások* listában minden eseménynél megjelenik a **1 / X / 2** három gomb.
* [ ] A felső sorban **Ország • Liga** látható; ha nincs adat, legalább a sport neve.
* [ ] A `create → finalize → payout` tesztelhető, mert van elérhető H2H piac.
* [ ] `flutter analyze` és `flutter test` zöld, a meglévő funkciók nem sérülnek.
