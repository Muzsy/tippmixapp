# Sprint 11 – Email‑egyediség ellenőrzés Cloud Functions nélkül

## Kontextus

A `isEmailAvailable()` jelenleg egy **Cloud Functions** callable‑t hív (`europe‑central2-checkEmail`). Mivel a függvény még nincs deployolva, a kliens **NOT\_FOUND** hibát kap, az App Check pedig 403‑at dob. Emiatt a regisztráció első lépése megakad.

A Firebase Auth SDK képes natívan ellenőrizni, hogy van‑e már fiók egy e‑mail címmel a **`fetchSignInMethodsForEmail()`** hívással – ehhez **nem kell** Cloud Functions, így App Check sem blokkolja.

## Cél

* Számoljuk fel a Cloud Functions függőséget az e‑mail egyediség vizsgálatnál.
* Refaktoráljuk az `AuthRepository.isEmailAvailable()` és a hívási láncát, hogy **közvetlenül a Firebase Auth** SDK‑t használja.
* Biztosítsuk, hogy debug buildben az App Check debug provider aktiválódik a Functions/Firestore hívásokhoz is (már megtörtént, de fennmarad).
* Frissítsük a teszteket a új implementációra.

## Feladatok

* [ ] **AuthRepository** – `isEmailAvailable()` implementáció cseréje `fetchSignInMethodsForEmail()`‑re.
* [ ] **Cloud Functions hívás eltávolítása**: töröljük a régiós callable sort és importot.
* [ ] Hibakezelés egységesítése: ha a fetch áthívás hibát dob (pl. offline) → `true` (fail‑open) + SnackBar warning.
* [ ] **Unit‑teszt**: mock FirebaseAuth, válasz üres ↔ nem üres lista.
* [ ] **Widget‑teszt**: foglalt email → SnackBar „Ez az e‑mail már foglalt”.
* [ ] **Integration‑teszt** (`integration_test/register_flow_email_check_refactor_test.dart`): emulatorral végigviszi a teljes regisztrációt, meggyőződik a hívásról és a `[REGISTER]` logokról.
* [ ] `flutter analyze` + `flutter test` zöld.

## Done Definition

* [ ] Regisztráció első lépése NEM fut Cloud Functions‑re, App Check 403 eltűnik.
* [ ] `[REGISTER] STARTED / SUCCESS` logok megjelennek.
* [ ] Tesztek ≥ 90 % lefedettség a `services/auth_repository.dart` új kódjára.

## Hivatkozások

Canvas → `/codex/goals/sprint11_email_check_refactor.yaml`
