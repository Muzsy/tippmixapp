# Fogadási oldal – P0/P1 javítások (H2H + szűrés)

🎯 **Funkció**

A fogadási oldal stabil és hatékony működésének helyreállítása:

* **P0**: helyes H2H (1X2) lekérés `bet=1`, duplikált lekérések megszüntetése, lokális‑első kártyalogika, `fixtureId<=0` guard.
* **P1**: a **dátumszűrő** bekötése a backend fixtures kérésbe + cache kulcs pontosítása.

🧠 **Fejlesztési részletek**

**Érintett fájlok**

* `lib/services/api_football_service.dart`
* `lib/widgets/event_bet_card.dart`
* `lib/screens/events_screen.dart` (vagy ahol a service hívás paraméterezése történik)
* `lib/services/odds_cache_wrapper.dart`
* (szűrősáv) `lib/widgets/events_filter_bar.dart`, `lib/features/filters/events_filter.dart`

**Problémák → Megoldások**

1. **Hibás `bet` paraméter**
   *Hiba*: `&bet=1X2` → API hiba (integer kell).
   *Megoldás*: `&bet=1` (H2H / Match Winner azonosító).

2. **Dupla/tripla odds lekérés**
   *Hiba*: a lista építése közben per‑fixture H2H is kérődik, majd a kártya újra kér → fölös terhelés, villogás.
   *Megoldás*: a lista **csak fixtures**‑t kér; H2H‑t **csak** a kártya kér, 60s memóriacache mellett.

3. **Kártya hálózat‑első**
   *Hiba*: a kártya már átadott H2H mellett is hálózatra megy.
   *Megoldás*: **lokális‑első**: először az `event.bookmakers` H2H, hiány esetén `FutureBuilder`.

4. **Érvénytelen `fixtureId`**
   *Hiba*: `int.tryParse(event.id) ?? 0` → `fixture=0` hívás is elmehet.
   *Megoldás*: `getH2HForFixture` elején guard: `if (fixtureId <= 0) return Future.value(null);`.

5. **Dátumszűrő lokális csak**
   *Hiba*: a szolgáltatás mindig „ma” napra kér; a választott nap nem jut le.
   *Megoldás*: `fixtures?date=YYYY‑MM‑DD` a választott napra; a cache kulcs egészül ki a dátummal (és opcionálisan ország/ligával).

**Kivonatolt implementációs jegyzetek**

* `api_football_service.dart`

  * URL építés: `.../odds?fixture=$id&bet=1` H2H‑hoz.
  * A `getOdds(...)` metódusból kivenni a per‑fixture odds hívásokat.
  * `getH2HForFixture(fixtureId, ...)`: guard + max 1 retry + 60s memóriacache `(fixtureId)` kulccsal.
* `event_bet_card.dart`

  * Renderelés: ha `event.bookmakers` → Match Winner (id==1 | name=="Match Winner") megtalálható, abból épül az 1‑X‑2; egyébként `FutureBuilder(getH2HForFixture)`.
* Dátum bekötés

  * A képernyő átadja a kiválasztott napot a service‑nek; a service `fixtures?date=YYYY‑MM‑DD`‑re épít.
  * Cache kulcs: `sport|date|country|league`.

🧪 **Tesztállapot**

*Új / frissített tesztek*

* **Service URL teszt**: H2H kérésnél `query['bet']=='1'`.
* **Fallback teszt**: üres H2H → második hívás **bet nélkül**, majd kliens oldali piacszűrés.
* **Kártya viselkedés**: ha az `event` már tartalmaz H2H‑t, **nincs** hálózati hívás; ha nincs, indul és megjelenik az 1‑X‑2.
* **Guard teszt**: `fixtureId<=0` → nincs hálózati hívás.
* **Dátum teszt**: kiválasztott nap → `fixtures?date=...` kerül a service URL‑be; a cache kulcsban is megjelenik.

*Futtatás*

* `flutter analyze`, `flutter test` kötelezően zöld.

🌍 **Lokalizáció**

* Szűrősáv „Bármelyik” (`filtersAny`) kulcs HU/EN/DE.
* A „Nincs elérhető piac” marad; várhatóan ritkábban jelenik meg.

📎 **Kapcsolódások**

* `canvases/betting_page_h2h_and_filters_fix.md` – előző részletes specifikáció.
* `canvases/h2h_odds_fetch_fix.md` – H2H alapfix.
* `Codex Canvas Yaml Guide.pdf` – kötelező séma.
* `Api Football Migration Plan.pdf` – szolgáltatóváltási referenciák.
