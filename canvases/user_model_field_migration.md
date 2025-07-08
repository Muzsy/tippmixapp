## 🎯 Funkció

Adatmigráció és adatséma‐szigorítás a `UserModel` mezőire, hogy a Splash képernyő ne ragadjon be, és a felhasználói dokumentumok konzisztens, kötelező adatokat tartalmazzanak.

## 🔍 Probléma röviden

A Firestore `users/{uid}` dokumentumok egy része nem tartalmazza a `uid`, `nickname`, `avatarUrl` stb. mezőket.
A `UserModel.fromJson()` ezekre kötelező `String` castot használ, így **null → String** kivételt dob, ami blokkolja az app indulását.

## 🧠 Fejlesztési részletek

### 1. Adatmigráció (一次 script vagy Cloud Function)

* Hozd létre: `functions/scripts/migrateUserSchema.ts`

* Végigiterál a **users** kollekción, és ahol egy mező hiányzik, alapértékkel pótolja:

  | Mező                      | Típus             | Alapérték            |
  | ------------------------- | ----------------- | -------------------- |
  | `uid`                     | String            | `doc.id`             |
  | `email`                   | String            | `''`                 |
  | `displayName`             | String            | `''`                 |
  | `nickname`                | String            | `''`                 |
  | `avatarUrl`               | String            | `kDefaultAvatarPath` |
  | `isPrivate`               | bool              | `false`              |
  | `fieldVisibility`         | Map\<String,bool> | `{}`                 |
  | `notificationPreferences` | Map\<String,bool> | `{}`                 |
  | `twoFactorEnabled`        | bool              | `false`              |
  | `onboardingCompleted`     | bool              | `false`              |
  | `schemaVersion`           | int               | `2`                  |

* Idempotens legyen (második futás sem változtat).

### 2. Modell szigorítása

* `lib/models/user_model.dart`

  * Távolítsd el az `?? ''` fallbackeket **email**, **displayName**, **nickname**, **avatarUrl** mezőknél.
  * Maradjon csak `as String` – a migráció után minden doksi tartalmazni fogja őket.
  * Adj `assert(uid.isNotEmpty && nickname.isNotEmpty)` a konstruktorhoz.

### 3. SplashController hibatűrés

* Wrap `UserModel.fromJson()` egy `try/catch`‑be.
* **catch** → `FirebaseAuth.instance.signOut()` + `router.goNamed(AppRoute.login.name)`.

### 4. Tesztek

* **unit**: `test/models/user_model_test.dart` – vizsgáld, hogy a factory dob‑e, ha hiányzik mező.
* **integration**: `test_driver/splash_test.dart` – betöltés után a Home képernyő jelenik meg.

### 5. CI

* `flutter analyze` és `flutter test` zöld legyen.
* Adj új GitHub Actions step‑et a migrációs script statikus ellenőrzéséhez.

## 🧪 Tesztállapot (kezdet)

* `splash_controller_test` ❌ (beragad Splash‑en)
* `user_model_test` ❌ (null mező cast)

Migráció + szigorítás után **minden tesztnek zöldnek kell lennie**.
