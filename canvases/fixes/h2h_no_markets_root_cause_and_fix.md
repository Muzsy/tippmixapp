# H2H „Nincs elérhető piac” – gyökérok és javítás

## Mi történt?

A tippkártyák **mindegyikén** a „Nincs elérhető piac” jelent meg. A kód átnézése után az ok **két helyen** azonosítható:

1. **Odds hívás hiányos paraméterezése**
   `ApiFootballService.getOddsForFixture()` csak a `fixture` paramétert küldi: `GET /odds?fixture=<id>`.
   Az API‑Football a **szezon** nélkül sok esetben **üres választ** ad. A `league.season` mező elérhető a fixtures válaszban, de **nem kerül továbbításra**.

2. **Piacnév aliasok szűk halmaza**
   A H2H (1X2) piac keresése a bet‑névben csak `"match winner"` és `"1x2"` mintákat engedett át. Sok ligában a H2H a `Full Time Result`, `Match Result` vagy `Winner` név alatt érkezik, így **nem találtuk meg**.

> Következmény: az események `bookmakers` listája üres maradt, az `EventsScreen` pedig `h2hMarket: null`‑t adott át az `EventBetCard`‑nak → megjelent a „Nincs elérhető piac”.

## Mit javítunk?

* Kiegészítjük az odds‑hívást a **szezon** paraméterrel: `GET /odds?fixture=<id>&season=<yyyy>&bet=1X2` (a `bet=1X2` szűkít és gyorsít).
* Az `OddsEvent` modell **opcionális `season`** mezőt kap (fixtures → model mapping).
* Bővítjük a H2H alias listát: `match winner`, `1x2`, `full time result`, `match result`, `winner`.
* Érték‑aliasok kezelése: a `values[].value` lehet `Home/Draw/Away`, de előfordul `1/X/2` is – ezt is lekezeljük.

## Változási hatókör

* **Nem törjük** a meglévő API‑t: az új `season` mező opcionális.
* Nem érintjük a Riverpod provider interfészét, az `EventsScreen` változatlanul működik.

## Elfogadási kritériumok

* [ ] Az `EventsScreen` **minden** aktív eseményén megjelenik az 1/X/2 gombsor.
* [ ] Legalább egy bajnokságban (pl. PL/LaLiga) tényleges odds értékek töltődnek be.
* [ ] `flutter analyze` és `flutter test` zöld.

## Kapcsolódó fájlok

* `lib/services/api_football_service.dart`
* `lib/models/odds_event.dart`
* (teszt) `test/services/api_football_service_odds_url_test.dart`
