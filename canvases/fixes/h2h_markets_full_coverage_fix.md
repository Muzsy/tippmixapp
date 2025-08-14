# H2H piacok – teljes lefedettség javítása

## 🎯 Funkció

A tippkártyákon **minden** eseménynél jelenjen meg a H2H (1–X–2) piac. Szűnjön meg az az állapot, amikor csak az első néhány kártyán látszanak a H2H gombok, a többin pedig **„Nincs elérhető piac”** jelenik meg.

## 🧠 Fejlesztési részletek

**Valószínű okok (több is érvényes lehet egyszerre):**

* **Index‑alapú FutureBuilder**: a piac‑lekérés Future‑je az **indexhez** kötött, nem a `fixtureId`‑hoz → görgetés/újrafelépítés közben rossz Future újrahasznosul.
* **Hiányzó/hibás cache‑kulcs**: a service/provideren belül a cache **nem `fixtureId` kulccsal** vagy **limitált mérettel** működik → csak az első N esemény kap adatot.
* **Market‑mapping filter**: az API‑Football a H2H‑t több néven adhatja (pl. `1x2`, `Match Winner`). Ha a mapping csak egy kulcsot enged át, a többi kártyán „nincs piacnak” látszik.
* **Párhuzamos lekérések**: túl agresszív concurrency → 429/timeout részleges üres eredménnyel.

**Javítási terv:**

1. **Service‑szintű cache per fixture**
   `ApiFootballService.getH2HForFixture(fixtureId)`

   * In‑memory cache: `Map<int, Future<H2HMarket?>> _h2hCache` **TTL**‑lel (pl. 60s), hogy ne kérjünk újra minden buildnél.
   * „in‑flight” kombináció: ugyanarra a `fixtureId`‑re csak **egy** hálózati kérés fusson.
2. **Kulcsok stabilizálása az UI‑ban**
   `FutureBuilder` és kártya **ValueKey('markets-<fixtureId>')**; a Future **mindig** `fixtureId`‑ból származzon.
3. **Market‑mapping bővítése**
   A H2H belső kódja (`Market.h2h`) fogadja el az API‑kulcsok közül: `"H2H"`, `"1x2"`, `"Match Winner"`.
   (A mapping fájlba kiterjesztett alias‑lista kerül.)
4. **Visszaesési logika és üzenet**
   Ha a hálózati hívás átmenetileg hibázik, egyszeri **retry** (pl. 300–500ms késleltetés). Csak **sikeres** üres eredmény esetén írjuk ki a „Nincs elérhető piac” szöveget.
5. **Egységes megjelenítés**
   A H2H gombok az `ActionPill` stílust használják (ezt a layout‑refaktor már egységesítette), így UI‑ban konzisztens.

## 🧪 Tesztállapot

* **Unit (service)**: cache működés (`fixtureId`‑onként egy hívás), TTL lejárat, „in‑flight dedupe”.
* **Unit (mapping)**: `H2H`/`1x2`/`Match Winner` → belső `Market.h2h`.
* **Widget**: több (pl. 20) kártya mock service‑szel; mindegyiken megjelenik a 3 H2H gomb.
  Hibás hívás szimuláció: első próbálkozás 429 → retry után megjelennek a gombok.

## 🌍 Lokalizáció

* Új kulcs nem szükséges. A „Nincs elérhető piac” meglévő kulcs marad; ritkábban fog látszani, mert a retry/cache miatt valóban csak **hiányzó** piacnál jelenik meg.

## 📎 Kapcsolódások

* `lib/services/api_football_service.dart` – H2H lekérő + cache/TTL + retry
* `lib/services/market_mapping.dart` – H2H aliasok
* `lib/widgets/event_bet_card.dart` – FutureBuilder kulcs, fixtureId‑alapú Future, ActionPill használat
* (teszt) `test/services/api_football_service_h2h_cache_test.dart`, `test/widgets/event_bet_card_h2h_coverage_test.dart`
