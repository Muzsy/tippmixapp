## 🧪 AuthService – Unit‑tesztek (Sprint5 ✓ T07)

### 🎯 Cél

Regressziós lefedés az **AuthService** minden kritikus viselkedésére – hálózat nélkül, 100 %-ban determinisztikusan.

| Use‑case                     | Elvárt viselkedés                                                                                                                   |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| **1. Sikeres bejelentkezés** | `login(email, pass)` → HTTP 200, JSON‑tokeneket elmenti `SecureStorage`‑ba, `AuthState.authenticated`-et küld a `authProvider`‑nek. |
| **2. Hibás jelszó**          | HTTP 401 → dob `AuthException.invalidCredentials`, nem ír storage‑ba.                                                               |
| **3. Szerver‑hiba**          | HTTP 500 → `AuthException.serverError`, retry **NEM** történik.                                                                     |
| **4. Refresh token**         | `refresh()` → HTTP 200, új access‑token mentve, refresh‑token változatlan.                                                          |
| **5. Expired refresh token** | HTTP 401 → `AuthState.loggedOut`, storage törlődik.                                                                                 |

### 🔧 Implementációs lépések

1. **Fake HTTP‑kliens**

   * `import 'package:http/testing.dart';`
   * `MockClient`‑et adunk át a konstruktorban → külön response funkciók minden use‑case‑hez.
2. **Fake SecureStorage**

   * In‑memory map implementáció, dependency injection‑nel adva az `AuthService`‑nek.
3. **Providers override**

   * `ProviderScope( overrides: [ authServiceProvider.overrideWithValue(fakeAuthService) ] )`.
4. **Tesztfuttatás**

   * `dart run test` – Codex környezetben nincs Flutter‑dependencia.
5. **Futás izoláció**

   * Minden teszt `setUp`‑ban új `AuthService` példány.

### ✅ Definition of Done

* Minden fenti use‑case‑re zöld teszt.
* Legalább **90 %** line‑coverage az `auth_service.dart`‑re (CI jelentésben látható).
* Tesztek max. **500 ms** alatt futnak.
* Nem hajt végre semmilyen valós hálózati hívást vagy `SharedPreferences`/Keychain‑műveletet.

### 🔗 Kapcsolódások

* **Forrás‑fájlok**

  * `lib/services/auth_service.dart`
  * `lib/providers/auth_provider.dart`
  * `lib/utils/secure_storage.dart`
* **Codex‑doksik**

  * `codex_docs/testing_guidelines.md`
  * `codex_docs/exception_handling.md`

---

*Ha rendben, a következő lépés a* `codex/goals/fill_canvas_auth_service_test.yaml` *létrehozása, amely ezen vászon alapján generálja a* `test/services/auth_service_test.dart` *fájlt.*
