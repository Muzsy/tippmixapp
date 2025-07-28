# Sprint10 – Cloud Functions régió & App Check debug provider

## Háttér

A `checkEmail` felhőfüggvény hiányzik a projektből, és a kliens alapértelmezés szerint `us‑central1` régiót hív. A backend azonban **`europe‑central2`**‑ben fog futni (l. screenshot). Emiatt a kliens **NOT\_FOUND** hibát kap, plusz a mobilon az App Check 403‑at dob, mert dev‑buildben nincs érvényes attesztáció.

## Cél

1. A kliens mindig a megfelelő régióban keresse a függvényt (offline és CI tesztekben is mockolva).
2. Debug / CI buildben az App Check ne blokkolja a hívást (Debug provider).
3. A Codex Testing Guidelines alapján **VM‑safe** unit és widget tesztekkel bizonyítsuk a működést (nincs emulátor).

## Feladatlista

| Lépés | Fájl                                                           | Művelet                                                                                                                 |
| ----- | -------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| 1     | `lib/services/auth_repository.dart`                            | *Refaktor:* `FirebaseFunctions.instanceFor(region: kFunctionsRegion)` + callable név: `'$kFunctionsRegion-checkEmail'`. |
| 2     | `lib/constants/firebase_constants.dart` *(új)*                 | `const kFunctionsRegion = 'europe-central2';`                                                                           |
| 3     | `lib/bootstrap.dart` v. `main.dart`                            | `FirebaseAppCheck.instance.activate(androidProvider: AndroidProvider.debug);` csak `kDebugMode` esetén.                 |
| 4     | **Unit‑teszt** `auth_repository_email_check_test.dart`         | Mockolt `FirebaseFunctions`, teszteli hogy a régiós callable hívódik.                                                   |
| 5     | **Widget‑teszt** `register_email_exists_shows_error_test.dart` | Mockolt AuthRepo→409, SnackBar megjelenik.                                                                              |
| 6     | CI parancsok a Guidelines szerint                              | `dart format .`, `flutter analyze --fatal-infos --fatal-warnings`, `flutter test --coverage`, coverage ≥90 %.           |

## Acceptance Criteria

* [ ] `AuthRepository.isEmailAvailable()` a `europe-central2` régiót használja.
* [ ] Debug buildben App Check token mindig generálódik (Debug provider).
* [ ] Unit + widget teszt PASS, coverage ≥90 %.
* [ ] `flutter analyze` hibamentes.

## Hivatkozások

Canvas → `/codex/goals/sprint10_functions_appcheck_fix.yaml`
Tesztelési elvek → *Codex Testing Guidelines.pdf*
