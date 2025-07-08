# Guest Home & RouteGuard Implementation – Sprint 5

> **Sprint type**: Feature implementation
> **Estimated effort**: 1 nap

---

## 🎯 Cél (Goal)

Biztosítani, hogy vendégfelhasználók (nem bejelentkezettek) egyértelműen a **Login/Regisztráció** flow felé legyenek terelve, és ne férjenek hozzá védett képernyőkhöz. Ezt két fő komponenssel érjük el:

1. **HomeGuest CTA** – Csempe a főképernyőn (Home) „Belépés / Regisztrálj” felirattal, ami a Login képernyőre navigál.
2. **RouteGuard** – Riverpod‑alapú wrapper (`RequireAuth`) minden védett route köré, amely ha `uid == null`, egy `LoginRequiredDialog` popupot mutat.

---

## 📂 Érintett/új fájlok

| Fájl                                          | Típus             | Leírás                                            |
| --------------------------------------------- | ----------------- | ------------------------------------------------- |
| `lib/screens/home_guest_cta_tile.dart`        | Widget            | Főképernyő csempéje Belépés/Regisztrálj actionnel |
| `lib/widgets/login_required_dialog.dart`      | Widget            | Route‑guard popup: magyarázat + Login gomb        |
| `lib/providers/auth_guard.dart`               | Riverpod Provider | `RequireAuth` wrapper a GoRouter‑hez              |
| `lib/router/router.dart`                      | Router            | Védett route‑ok RequireAuth köré integrálása      |
| `integration_test/guest_routeguard_test.dart` | e2e‑test          | BetSlip → popup ellenőrzés                        |
| `.github/workflows/flutter_ci.yaml`           | CI                | `flutter drive` step vendég‑flow‑ra               |

---

## ✅ Feladatlista

1. **HomeGuest CTA Tile** – Helyezd el a Home screen gridjében; `InkWell` → `context.goNamed(AppRoute.login)`.
2. **AuthGuard Provider** – `RequireAuth` komponens (`ConsumerWidget`) figyeli `authStateProvider`; ha nincs `uid`, `showDialog(LoginRequiredDialog)` és visszatér `SizedBox.shrink()`; egyébként `child`.
3. **Route integráció** – BetSlip, Profile, History, Settings útvonalak `RequireAuth`‑ba csomagolása a `router.dart`‑ban.
4. **LoginRequiredDialog** – Material 3 kártya, magyarázat, két gomb: „Mégsem” (Navigator.pop) és „Belépés” (goNamed Login).
5. **e2e‑test** – `flutter drive` teszt: vendég BetSlip‑re tap → popup; gombok működnek.
6. **CI guard** – új e2e step GitHub Actions‑ben.

---

## 📋 Definition of Done

* HomeGuest CTA navigál a Login‑re HU/EN/DE lokalizációval.
* Minden korlátozott route popupot dob vendégnek.
* e2e‑ & widget‑tesztek zöld; CI coverage ≥ 80 %.
* Accessibility: dialog‑nak semanticsLabel, CTA‑nak minimum 48 x 48 hittarget.

---

## 🚧 Korlátozások & Guard‑rails

* Globális state továbbra is Riverpod; nincs `setState` kapcsoló a RouteGuardban.
* Popup maximum 2 action gomb; extra link tilos.
* Bináris asset commit tilos.
* Stringek `.arb`‑ba.

---

## 🔄 Output (Codex → Repo)

```yaml
outputs:
  - lib/screens/home_guest_cta_tile.dart
  - lib/widgets/login_required_dialog.dart
  - lib/providers/auth_guard.dart
  - lib/router/router.dart
  - integration_test/guest_routeguard_test.dart
  - .github/workflows/flutter_ci.yaml
  - l10n/.arb (kulcs‑update)
```

---

*Ez a vászon a Sprint 5‑höz tartozik, a vendég‑CTA‑t és a route‑guardot valósítja meg.*
