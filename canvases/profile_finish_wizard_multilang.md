# Auth – Profil‑befejezés Wizard (hu · en · de) – Sprint 10

> **Sprint típusa**: Feature‑finishelés + UX‑flow
> **Becsült effort**: 2 nap (fejlesztés) + 1 nap (review / QA)

---

## 🎯 Cél

A regisztráció + email‑verifikáció után a felhasználó egy **rövid „Profil‑befejezés” wizard** képernyőn egészítse ki elsődleges adatait. A wizard háromnyelvű (`hu`, `en`, `de`) és reszponzív legyen, mobil‑first dizájnnal.

### Funkcionális elvárások

1. **Profil‑modell** (`UserProfile`):

   * kötelező mező: `displayName` (2–32 karakter);
   * opcionális: `avatarUrl`, `referralCode` (alfa‑numerikus, max 12 karakter);
   * rendszermezők: `coins = 1000`, `createdAt`, `updatedAt`.
2. **Firestore‑service**: `createUserProfile()` & `updateUserProfile()` wrapper metódusok a `users/{uid}` gyűjteményhez.
3. **Wizard UI** – két lépés:

   1. **Display Name** + jelszó‐erősség‑feedback továbbvitt UI‑minták szerint.
   2. **Avatar‑feltöltés & (opcionális) referral kód**.
4. **Átirányítás**: az `AuthGate` csak akkor enged a fő dashboardra, ha `profileCompleted == true`.
5. **i18n**: minden string három nyelven, `intl/arb`‑fájlok frissítése.
6. **Biztonsági szabályok**: Cloud Firestore rules → felhasználó csak **saját** profilját írhatja (patch‑update), „coins” mezőt nem módosíthatja kliensoldalról.
7. **Teszt coverage ≥ 80 %**: unit (validator, service) + widget (UI lépések) tesztek + integration (navigáció flow).
8. **CI**: `flutter test`, `flutter analyze`, HIBP + reCAPTCHA stubok ne törjenek.

### Nem‑cél

* Közösségi avatar‑generátor (Gravatar, stb.) integráció.
* Webes Firebase Auth UI komponensek.

---

## Deliverable‑lista

| Fájl                                     | Leírás                                    |
| ---------------------------------------- | ----------------------------------------- |
| `lib/models/user_profile.dart`           | Dart‑adatmodell + `fromJson`/`toJson`     |
| `lib/services/user_profile_service.dart` | Firestore wrapper‑módszerek               |
| `lib/screens/profile_wizard/`            | `Step1DisplayNamePage`, `Step2AvatarPage` |
| `lib/widgets/avatar_picker.dart`         | Reusable kép‑választó komponen..."}       |
