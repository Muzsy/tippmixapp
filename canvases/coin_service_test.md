## 🧪 CoinService – Unit‑tesztek (Sprint5 ✓ T10)

### 🎯 Cél

A **CoinService** összes kritikus funkciójának determinisztikus regressziós lefedése – vásárlás, egyenleg‑lekérdezés, jutalmak jóváírása és hibakezelés.

---

### 1. Tesztelt use‑case‑ek

| #     | Forgatókönyv                                                                            | Elvárt eredmény                                                                             |
| ----- | --------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| **1** | **Egyenleg‑lekérdezés – cache hit**: `getBalance(uid)` → memória‑cache találat          | Nincs HTTP‑hívás, visszatér a cache-elt `CoinBalance`, `balanceProvider` → `BalanceLoaded`. |
| **2** | **Egyenleg‑lekérdezés – cache miss**: nincs cache → HTTP 200 válasz                     | Balance modell elmentve cache‑be, provider állapota frissül.                                |
| **3** | **Sikeres coin‑vásárlás**: `purchase(uid, 500)` → HTTP 201, új egyenleg                 | `CoinPurchaseSuccess` event, cache frissül.                                                 |
| **4** | **Elégtelen egyenleg**: `spend(uid, 1000)` amikor balance<1000                          | `InsufficientCoinsException` dobódik, provider állapota változatlan.                        |
| **5** | **Jutalom jóváírás (reward)**: `reward(uid, 50)` offline → sorba tesz, majd online sync | Lokális queue → online sync után balansz nő 50‑nel, cache frissül.                          |
| **6** | **Rate‑limit**: HTTP 429 és `Retry‑After`                                               | Retry logic betartja a headerben kapott időt, végül siker vagy `CoinApiRateLimitException`. |

---

### 2. Implementációs lépések

1. **Fake HTTP‑kliens** a `http/testing.dart`‑tal – konfigurálható válaszsorozatok (200, 201, 400, 429 stb.).
2. **FakeMemoryCache** – Map alapú, minden tesztben tiszta állapot.
3. **FakeConnectivity** – bool flag online/offline váltáshoz.
4. **Dependency‑injection**: a teszt a `CoinService(Dio dio, Cache cache, Connectivity conn)` konstruktorát használja.
5. **`withClock`** → determinisztikus timestampek.
6. Tesztfájl: `test/services/coin_service_test.dart`.

---

### 3. Definition of Done

* 5+ use‑case teszt zöld, 85 %+ line coverage a `coin_service.dart`‑on.
* Nincs valós hálózati hívás; minden negatív és pozitív ág assertálva.
* Tesztek **≤ 60 s** alatt futnak CI‑ben.

---

### 4. Tiltások & kötelezők

* ❌ `Future.delayed`, `sleep` → használj fake wall‑clockot.
* ❌ Megosztott állapot teardown nélkül.
* ✅ Háromnyelvű lokalizáció **nem szükséges** (service‑szint).

---

### 5. Kapcsolódó források

* `lib/services/coin_service.dart`
* `lib/providers/coin_provider.dart`
* `lib/utils/cache.dart`
* `lib/utils/connectivity.dart`
* `codex_docs/testing_guidelines.md`
