# Sprint 6 — Email/Jelszó regisztráció — App Check token try/catch

## Kontextus

A **lib/services/auth\_service.dart** fájlban a `registerWithEmail()` még
mindig közvetlenül meghívja
`FirebaseAppCheck.getToken(true)`‑t **hiba‑kezelés nélkül**. Ha a debug
vagy release környezetben a token‑kérés *bármilyen okból* kivételt dob
(pl. token nincs whitelisten, hálózat hiba), a teljes regisztrációs
folyamat megszakad. A crash‑t nem fogja a meglévő `on
fb.FirebaseAuthException` blokk, mert ez más típusú (`FirebaseException`)
hiba.

## Cél (Goal)

* A regisztráció **soha ne omoljon el** App Check token‑hiba miatt.
* Production buildben *továbbra is* működjön a Play Integrity/App Attest
  védelem; a patch csak debug/dev körben legyen hatásos.

## Feladatok

* [ ] **auth\_service.dart** — importáljuk a `firebase_core` csomagot, és
  wrapeljük a `getToken()` hívást `try/catch`‑be.
* [ ] Töröljük a fel nem használt `appCheckToken` változót, hogy ne jöjjön
  lint‑warning.
* [ ] **Teszt**: `registerWithEmail` ne dobjon, ha `getToken()` kivételt
  ad vissza (mockolt App Check‑szel).

## Acceptance Criteria

* [ ] `flutter analyze` hibamentes (nincs unused‑variable).
* [ ] Az új widget/unit teszt zöld (`flutter test`).
* [ ] Manual QA: debug buildben kiherélt tokennel is végigfut a
  regisztráció, email‑verifikációs mail kimegy.

## Hivatkozások

* Log: `Error getting App Check token; … 403 body: App attestation failed.`
* Kapcsolódó canvas: `register_app_check_fix.md` (P1).
