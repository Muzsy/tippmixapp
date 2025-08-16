# Fogadási oldal – H2H odds és szűrés javítása (API‑Football)

🎯 **Funkció**

A fogadási oldal (fixtures + tipkártyák) stabil, felesleges lekérésektől mentes működése.

* Helyes H2H (1X2 / Match Winner) lekérés `bet=1` paraméterrel.
* A lista csak **fixtures**‑t kér, a H2H oddsot a kártya tölti **cache**‑elve.
* A kártya először a **lokális** (átadott) H2H‑t használja, csak hiány esetén megy hálózatra.
* Guard a hibás `fixtureId<=0` ellen.
* A szűrősáv (dátum / ország / liga) **valóban** befolyásolja a **szerverlekérést** is.

🧠 **Fejlesztési részletek**

**Érintett fájlok**

* `lib/services/api_football_service.dart`
* `lib/widgets/event_bet_card.dart`
* `lib/widgets/events_filter_bar.dart`
* `lib/features/filters/events_filter.dart`
* (cache) `lib/services/odds_cache_wrapper.dart`
* (tesztek) `test/services/...`, `test/widgets/...`

**Problémák és megoldások**

1. **Hibás bet paraméter**
   *Probléma*: `&bet=1X2` → API hiba (integer kell).
   *Megoldás*: `&bet=1` (H2H / Match Winner azonosító).

2. **Felesleges odds‑hívások a listaépítésben**
   *Probléma*: `getOdds(...)` minden fixture után H2H‑t is kér; a kártya újra kéri.
   *Megoldás*: a lista **nem** kér H2H‑t; csak fixtures jön. A kártya kéri a H2H‑t **60s memóriacache** mellett.

3. **Kártya: előbb lokális adat, majd hálózat**
   *Megoldás*: a `EventBetCard` render előtt megpróbálja az `event.bookmakers`‑ből kinyerni a H2H‑t (Match Winner). Ha nincs, **akkor** indul `FutureBuilder` a `getH2HForFixture(...)`‑re.

4. **Guard érvénytelen fixtureId ellen**
   *Megoldás*: `getH2HForFixture(...)` elején `if (fixtureId <= 0) return Future.value(null);`.

5. **Dátumszűrő bekötése a service‑be**
   *Probléma*: a szűrés eddig lokális volt; a service mindig „ma” napra kérdezett.
   *Megoldás*: a `getOdds(...)` átveszi a választott napot és `fixtures?date=YYYY‑MM‑DD` szerint kér; az `OddsCacheWrapper` kulcsa tartalmazza a napot is.

6. **Ország/Liga dropdown – „Bármelyik” opció**
   *Megoldás*: a dropdownok első eleme üres (i18n kulcs: `filtersAny`), logikában a `null` érték jelentse azt, hogy az adott dimenzió **nem** szűr.

7. **Időzítések és retry**
   *Megoldás*: a H2H hívás max. 1 retry (rövid késleltetéssel), timeout 8–10s.

8. **Cache stratégia**
   *Megoldás*: `getH2HForFixture` – 60s TTL memóriacache `(fixtureId)` kulccsal; a fixtures listára a wrapper cache kulcs: `(sport|date|country|league)`.

**Várható hatás**

* API‑hívások száma csökken (N kártya → N H2H, cache‑elve), a lista gyorsul.
* A kártyákon a H2H (1‑X‑2) gombok stabilan látszanak, scrollnál nem tűnnek el.
* A szűrő valódi szerveroldali szűrést is eredményez (konszisztensebb lista, kisebb adatmennyiség).

🧪 **Tesztállapot**

*Új / frissített tesztek*

* **Service URL teszt**: H2H kérésnél `query['bet'] == '1'`.
* **Fallback teszt**: üres H2H válasz → második hívás **bet nélkül**, majd kliens oldali piacszűrés.
* **Kártya viselkedés teszt**: ha az `event` már tartalmaz H2H‑t, **nincs** hálózati hívás; ha nincs, indul és megjelenik az 1‑X‑2.
* **Guard teszt**: `fixtureId<=0` → nincs hálózati hívás.
* **Szűrés teszt**: kiválasztott nap → `fixtures?date=...` kerül a service URL‑be; cache kulcs a dátumot is tartalmazza.

*Futtatás*

* `flutter analyze` (warning‑mentes)
* `flutter test` (új tesztekkel)

🌍 **Lokalizáció**

* Új kulcs: `filtersAny` (HU/EN/DE).
* A meglévő „Nincs elérhető piac” kulcs marad; várhatóan ritkábban jelenik meg.

📎 **Kapcsolódások**

* API‑Football átállás: *Api Football Migration Plan.pdf*
* Szelvénykezelés: *Canvases\_ticket Management Detailed Logic.pdf*
* H2H odds fix: *canvases/h2h\_odds\_fetch\_fix.md*
* Codex szabályok: *Codex Canvas Yaml Guide.pdf*
