# H2H – vizsgalat.txt alapján: `season` + kétlépcsős odds fallback

## Összefoglaló

A feltöltött **vizsgalat.txt** megállapításai a repo tényleges kódjára igazak: a `lib/services/api_football_service.dart` jelenleg a H2H minimál piacot úgy építi fel, hogy a fixtures‑ből képzett eseményekhez **`getOddsForFixture(e.id)`** hívással kér oddsot, **season nélkül** és **fallback nélkül**. Emiatt több bajnokságban üres a válasz → minden kártyán „Nincs elérhető piac”.

## Mit javítunk

1. **`OddsEvent` modell bővítése** opcionális `season` mezővel, hogy a fixtures `league.season` értéke meglegyen az odds lekéréshez.
2. **`_mapFixtureToOddsEvent`** állítsa az `OddsEvent.season` mezőt (`league['season']`).
3. **`getOddsForFixture(fixtureId, {season, includeBet1X2=true})`**: az URL tartalmazza a `&season=YYYY`‑t; első körben `&bet=1X2`, ha üres a `response`, **fallback** ugyanerre **bet nélkül**.
4. A fixtures→events dúsítás során a hívás legyen: `getOddsForFixture(e.id, season: e.season)`.
5. **Alias bővítés** a parserben: a H2H bet neve elfogadja a `match winner` és `1x2` mellett a `full time result`/`match result`/`winner` neveket is.

## Done/Acceptance

* [ ] Minden olyan eseménynél, ahol az API szolgáltat 1X2/Match Winner piacot, megjelenik a H2H gombsor.
* [ ] Az első kérés `bet=1X2`‑vel megy; üres válasz esetén második körben teljes odds jön.
* [ ] `flutter analyze` és `flutter test` zöld.

## Érintett fájlok

* `lib/models/odds_event.dart`
* `lib/services/api_football_service.dart`
* (teszt) `test/services/api_football_service_odds_fallback_test.dart`

## Megjegyzés

A jelenlegi UI ( `lib/screens/events_screen.dart` ) az `OddsApiData.events[*].bookmakers`‑ből adja az `EventBetCard.h2hMarket`‑et; **az EventBetCard‑ban nincs FutureBuilder**, így a javítás teljesen **service‑oldali**.
