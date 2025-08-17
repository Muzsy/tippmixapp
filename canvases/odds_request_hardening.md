# /odds hívás „betonbiztos” generálása – elemzés és javítás

## Probléma

A felhasználói logban megjelenik a `[odds] GET …/v3/odds?fixture=…` sor, **de az API‑Football dashboardon nem látszik** kimenő `/odds` kérés. Ezzel szemben a `/fixtures` hívások rendben megjelennek és érkeznek.

## Összehasonlítás: hívási láncok

* **/fixtures** (lista): `ApiFootballService.getOdds(…)` – a konkrét HTTP‑küldés itt történik:

  ```dart
  Future<http.Response> attempt() =>
      _client.get(Uri.parse(url), headers: {'x-apisports-key': apiKey})
              .timeout(const Duration(seconds: 10));
  ```
* **/odds** (kártya → H2H): `ApiFootballService.getH2HForFixture(…) → _fetchH2HForFixture(…) → getOddsForFixture(…)` – a konkrét HTTP‑küldés itt történik:

  ```dart
  Future<http.Response> attempt() =>
      _client.get(uri, headers: headers)
             .timeout(const Duration(seconds: 10));
  ```

## Lehetséges gátló tényezők (a most feltöltött kód alapján)

1. **Érvénytelen fixtureId** a kártyán

   * A kártya így hív: `int.tryParse(event.id) ?? 0`. Ha az `id` bármilyen nem numerikus karaktert tartalmaz, a guard (`fixtureId <= 0`) miatt **nem indul hívás**.
2. **Szezon hiánya**

   * Az `/odds` akkor a legpontosabb, ha tartalmaz `season` paramétert; ha az `event.season == null`, a kérés ugyan létrejön, de a szolgáltató válasza ingadozhat. Érdemes fallbackként az esemény évét használni.
3. **Túl nagy válasz / bookmakerek szűrésének hiánya**

   * A jelenlegi kérés nem szűri `bookmaker` szerint, így nagy válasz jöhet. Ez nem akadályozza a kimenő kérést, de növeli az időzítés/hálózati hibák esélyét; ráadásul a H2H‑hoz úgyis csak egy preferált bookmaker kell.
4. **Diagnosztika hiánya**

   * A logban látjuk az URL‑t (assert alatt), de **nincs visszaigazolás** a státuszkódra. Nehéz eldönteni, eljut‑e a szerverig, kapunk‑e 4xx/5xx‑öt, vagy kliens oldalon esik el a hívás.

## Javítások (minimális, célzott módosítások)

1. **Robusztus fixture azonosító**

   * A kártyán Regex‑alapú fallback: ha a `tryParse` elbukik, kinyerjük az első számot az `id`‑ből. Így a `fixtureId<=0` guard nem tilt le tévesen.
2. **Szezon‑fallback**

   * Ha `event.season == null`, használjuk `event.commenceTime.year` értékét a kérésben.
3. **Bookmaker szűkítés**

   * Adjunk hozzá `bookmaker=<defaultBookmakerId>` query paramétert a `/odds`‑hoz. Ez csökkenti a payloadot, stabilabb választ ad és nem érinti a mappinget (a preferált bookmaker úgyis azonos).
4. **Diagnosztikai státuszlog**

   * Assert alatt logoljuk a visszaérkező státuszkódot: `[odds] RES <status>`. Ezzel gyorsan látható, hogy a kérés tényleg kiment‑e és mit válaszolt a szerver.

## Várható hatás

* A kártyák **következetesen** elindítják az `/odds` hívást.
* A szolgáltatói dashboardon megjelennek a `/v3/odds` sorok.
* Kisebb válaszméret a `bookmaker` szűkítés miatt.
* Jobb terepi diagnosztika a státuszloggal.

## Elfogadási kritériumok

* A konzolban egy kártya megnyitásakor két log jelenik meg:

  1. `[odds] GET https://v3.football.api-sports.io/odds?...`
  2. `[odds] RES 200` *(vagy tényleges státuszkód)*
* Az API‑Football dashboard „Requests” alatt a `/v3/odds` kérések látszanak.
* A H2H (1/X/2) oddsok megjelennek a tippkártyán, ha az API szolgáltat piacot.

## Érintett fájlok

* `lib/widgets/event_bet_card.dart`
* `lib/services/api_football_service.dart`

---

### Megjegyzés

A módosítások **nem érintik** a meglévő üzleti logikát (cache, fallback, 429‑retry), csak robusztusabbá teszik a hívás indítását és a láthatóságát.
