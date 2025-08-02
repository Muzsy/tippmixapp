# Sprint4 – Látható hibakezelés a regisztrációban (Email‑foglaltság, kötelező mezők)

## Kontextus

Az első és második lépésen több validáció csendben megbukik:

- **H‑2** E‑mail foglaltság ellenőrzése: az `AuthRepository.isEmailAvailable()` 409‑re kivételt dob, ami elnyelődik, a felhasználó nem kap visszajelzést.
- **H‑3** Step 2 mezőhibák (születési dátum, GDPR‑pipa): a gomb disable‑logikája miatt a hibaüzenetek nem jelennek meg.

## Cél

Felhasználóbarát hibajelzés minden olyan esetben, amikor a kitöltés vagy a háttér‑ellenőrzés hibára fut.

## Feladatok

- [ ] **Email foglaltság kezelése**

  - `register_step1_form.dart`: csomagoljuk az `isEmailAvailable` hívást `try/catch`‑be.
  - `catch`‑ágban mutassunk `SnackBar`‑t: *"Ez az e‑mail már foglalt"*.
- [ ] **Gomb‑disable logika eltávolítása Step 2‑n**

  - `register_step2_form.dart`: a **Tovább** gomb akkor is aktív, ha mezők hibásak.
  - A gomb `onPressed`‑ében hívjuk a form `validate()`‑t; ha hamis, mutassunk SnackBar‑t.
  - A dátum‑, valamint GDPR‑checkbox hibáknál jelenjen meg a lokális `_showDateError` / `_showConsentError` hívás.
- [ ] **Widget‑tesztek**

  - `email_already_in_use_shows_error`: mock `AuthRepository.isEmailAvailable()` 409‑re; assertáljuk, hogy `SnackBar` megjelenik.
  - `step2_missing_consent_shows_error`: nem pipáljuk ki a checkboxot; assert, hogy SnackBar jelenik meg, és nem lépünk Step 3 ‑ra.
- [ ] `flutter analyze`, `flutter test` zöld.

## Acceptance Criteria

- [ ] Foglalt e‑mail esetén SnackBar „Ez az e‑mail már foglalt.”
- [ ] Hibás vagy hiányzó Step 2 mezők esetén SnackBar „Hiányos adatok, kérlek töltsd ki!”
- [ ] A Tovább gomb minden esetben aktív, de hibás adatnál nem lapoz tovább.
- [ ] Minden teszt zöld, analyze hibamentes.

## Hivatkozások

- Canvas → `/codex/goals/sprint4_validation_errors.yaml`
- Részletes hibaleírások a korábbi audit jelentésben.
