## 🧪 OddsApiService – Unit‑tesztek (Sprint5 ✓ T08)

### 🎯 Cél

Teljes regressziós lefedés az **OddsApiService** működésére, különös tekintettel a gyorsítótár‑kezelésre, a retry‑logikára és a kvóta/rate‑limit kezelésére.

| Use‑case                  | Elvárt viselkedés                                                                                                  |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| 1. **Cache hit**          | `getOdds(matchId)` → talált elem a mem‑cache‑ben → **nincs** HTTP‑hívás, visszatér a cache‑elt `OddsModel`.        |
| 2. **Cache miss**         | Cache üres → HTTP 200 válasz JSON‑nal → modell parse, cache‑be ment, és visszaadva.                                |
| 3. **Retry success**      | Első HTTP‑hívás időtúllépés (`SocketException`), második próbálkozás 200 → sikeres eredmény, max 2 próbálkozás.    |
| 4. **Max retry exceeded** | Három egymást követő hálózati hiba után `OddsApiException.retryFailed` dobódik.                                    |
| 5. **Rate‑limit (429)**   | Szerver 429 + `Retry-After: 2` → service **2 másodpercet késleltet**, majd újrapróbál; siker esetén adat cache‑be. |

### 🛠️ Implementációs lépések

1. **Mock HTTP kliens** – használjuk a `http/testing.dart`‑ot (`MockClient`). Egyéni `handler` függvénnyel szimuláljuk a válaszokat / hibákat.
2. **FakeCache** – egy egyszerű `Map<String, OddsModel>` implementáció, amit a konstruktorba injektálunk.
3. **clock package** – az időalapú lejárat teszteléséhez (ha a service TTL‑t is kezel).
4. **Dependency‑injection** – `OddsApiService(httpClient, cache, clock)`; tesztben minden függőség fake.
5. **dart run test** – a Codex környezetben nem hívunk Flutter‑parancsot.

### ✅ Definition of Done

* Minden fenti use‑case fedett, **≥ 90 % statements & branches** `odds_api_service.dart`‑re.
* Tesztek komplett offline; nincs valós hálózati hívás.
* Negatív esetek assertálva (`throwsA(isA<OddsApiException>())`).
* Localization nem érintett – itt csak angol log‑/hibaüzenetek.
* Zöld CI.

### 🔗 Kapcsolódások / bemeneti fájlok

* `lib/services/odds_api_service.dart`
* `lib/utils/cache.dart` *(ha van, különben FakeCache definiálva a tesztben)*
* `lib/providers/odds_provider.dart`
* `test/mocks/http_client_mock.dart` (létezés esetén; egyébként Codex generál)
* `codex_docs/testing_guidelines.md`

---

*Megjegyzés:* Szükség esetén a `Retry-After` fejléchez tartozó késleltetést a **clock** léptetésével teszteljük; ezzel determinisztikus marad a futásidő (nincs valódi `sleep`).
