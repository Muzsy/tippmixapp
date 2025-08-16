# H2H piacok – `season` paraméter és kétlépcsős odds‑fallback

## Probléma

A kártyák H2H (1X2) gombjai nem jelentek meg; a H2H lekérés a **fixture** alapján történt, **season** nélkül, ezért több ligánál üres odds‑válasz érkezett. A javítás lényege: a **season** mindenütt átadása, plusz egy **fallback** második körös lekérésre, ha a `bet=1X2` szűkített kérés mégis üres. (Forrás: H2h Market Fix.pdf – gyökérok és megoldási javaslat, valamint a kódrészlet az aláírt függvény‑szignatúrákkal és a UI‑hívással.)

## Cél

* `ApiFootballService.getH2HForFixture(int fixtureId, {int? season})` + `_fetchH2HForFixture(..., {season})` bevezetése.
* Az `event_bet_card.dart` FutureBuilderje **season**‑nel hívja a service‑t.
* Odds lekérés két lépésben:

  1. `odds?fixture=...&season=...&bet=1X2`
  2. ha üres → `odds?fixture=...&season=...` (szűrés nélkül)
* A meglévő H2H parser (API‑Football `response→bookmakers→bets→values`) használata változatlanul.

## Elfogadási kritériumok

* [ ] A H2H gombsor **minden** kártyán megjelenik, ahol az API valós oddsot ad vissza.
* [ ] A service elsőként `bet=1X2`‑vel kér, és csak üres válasz esetén kér újra.
* [ ] `flutter analyze` és `flutter test` zöld.

## Érintett fájlok

* `lib/services/api_football_service.dart`
* `lib/widgets/event_bet_card.dart`
* (teszt) `test/services/api_football_service_odds_fallback_test.dart`

## Megjegyzések

* Ha az esemény modell (`OddsEvent`) már tartalmazza a `season` mezőt, azt adjuk tovább; ha nem, opcionális paraméter marad.
* A korábbi cache (ha van) kulcsát érdemes `"<fixtureId>-<season>"` formára bővíteni, hogy szezonváltásnál ne legyen keveredés.

## Forrás hivatkozások

* A hiba oka és a javítás iránya: season hiányzik a H2H hívásból; a UI‑ból season átadás szükséges.
* Kétlépcsős odds‑fallback (`bet=1X2` → teljes odds), és a konkrét metódus‑szignatúrák.
