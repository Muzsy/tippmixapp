## 🧪 ProfileService – Unit‑tesztek (Sprint5 ✓ T09)

### 🎯 Cél

Reprodukálható, hálózat‑független egységtesztek a **ProfileService** összes kritikus útvonalára.

---

### 1. Tesztelt use‑case‑ek

| #     | Forgatókönyv                                                                                       | Elvárt kimenet                                                                                      |
| ----- | -------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| **1** | **Online profil‑letöltés** – `getProfile(uid)` → FakeFirestore **200 OK**                          | `ProfileModel` visszatér, `profileProvider` → `ProfileLoaded`, modell cache‑elve (`SecureStorage`). |
| **2** | **Offline cache‑hit** – hálózati hiba (`FirebaseException(code: network‑error)`), de cache létezik | Szolgáltatás visszaadja a cache‑elt profil‑modellt, provider állapot marad `ProfileLoaded`.         |
| **3** | **Profil‑frissítés siker** – `updateProfile(uid, map)` FakeFirestore **merge** sikerrel            | `ProfileUpdated` event, helyi cache frissül.                                                        |
| **4** | **Frissítés jogosultság‑hiba** – FakeFirestore `permission‑denied`                                 | `ProfileUpdateFailure` (CustomException), provider → `ProfileError`.                                |
| **5** | **Cache miss + offline**                                                                           | Hálózati hiba + üres cache → `ProfileServiceException.noCache`.                                     |

---

### 2. Implementációs lépések

1. **FakeFirestore**: használj `mock_cloud_firestore` vagy `FakeFirebaseFirestore()` (könyvtár a `dev_dependencies`‑ben).
2. **FakeConnectivity**: bool‑flag alapján dobjon `FirebaseException(network‑error)`‑t.
3. **FakeSecureStorage**: lásd `testing_guidelines.md` 13.1 példa.
4. **Dependency‑injection**: `ProfileService(firestore: fake, storage: fake, connectivity: fake)`.
5. **Órakezelés**: időbélyegekhez `withClock(Clock.fixed(...))`.
6. **Futtatás**: *nem* futtatunk tesztet Codex‑konténerben, csak fájl‑generálás; CI végzi a `dart run test`‑et.

---

### 3. Definition of Done

* **≥ 85 %** line coverage a `lib/services/profile_service.dart`‑re.
* Nincs valós Firestore‑ vagy hálózati hívás.
* Negatív és pozitív ágon is assertálunk provider‑állapotot.
* Tesztidő < 60 s a CI‑ben.

---

### 4. Kapcsolódó forrásfájlok

* `lib/services/profile_service.dart`
* `lib/providers/profile_provider.dart`
* `lib/utils/secure_storage.dart`
* `testing_guidelines.md` (ezen irányelvek kötelezőek)

---

### 5. Megjegyzések

* Valamennyi teszt a `test/services/profile_service_test.dart` fájlba kerüljön.
* Kerüld a `sleep`/`Future.delayed` hívásokat; fake clock‑kal tesztelj.
* A FakeFirestore‑t minden tesztben `setUp`/`tearDown` blokkal reseteld.
