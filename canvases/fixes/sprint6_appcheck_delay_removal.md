# Sprint6 – Mesterséges késleltetés eltávolítása és App Check token lekérés

## Kontextus

**H‑5**: Az `AuthService.registerWithEmail()` elején található

```dart
await Future.delayed(Duration(seconds: 2));
```

csak a korábbi versenyhelyzetet kerülte ki, de feleslegesen lassítja a regisztrációt.
A Firebase App Check tokent a hívás elején *azonnal* le lehet kérni.

## Cél

* A regisztráció a mesterséges 2 s késleltetés nélkül fusson le.
* A tokent biztonságos módszerrel kérjük le; hibakezeléssel és debug‑loggal.

## Feladatok

* [ ] `auth_service.dart`: távolítsuk el a `Future.delayed` sort.
* [ ] Helyette:

  ```dart
  final appCheckToken = await FirebaseAppCheck.instance.getToken(true);
  if (kDebugMode) print('[APP_CHECK] token: $appCheckToken');
  ```
* [ ] **Importok**: `package:firebase_app_check/firebase_app_check.dart` és `package:flutter/foundation.dart` (ha hiányozna).
* [ ] **Unit‑teszt** `register_completes_without_delay_test.dart`:

  * FakeAsync használatával ellenőrizni, hogy a metódus ≤100 ms alatt teljesül.
  * Mockolt `FirebaseAuth`, `FirebaseAppCheck`.
* [ ] `flutter analyze`, `flutter test` zöld.

## Acceptance Criteria

* [ ] `registerWithEmail()` nem tartalmaz `Future.delayed` hívást.
* [ ] Debug‑konzolban `[APP_CHECK] token:` megjelenik.
* [ ] A teszt 100 ms belül sikeresen lefut.
* [ ] Nincs analyze‑figyelmeztetés.

## Hivatkozás

* Canvas → `/codex/goals/sprint6_appcheck_delay_removal.yaml`
