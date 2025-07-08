# Forgot Password & Reset Flow Implementation – Sprint 7

> **Sprint type**: Feature implementation
> **Estimated effort**: 1 nap

---

## 🎯 Cél (Goal)

Teljes **Jelszó‑visszaállítás** folyamat (Forgot Password) bevezetése:

1. **ForgotPasswordScreen** – e‑mail bekérés, „Reset link küldése” CTA.
2. **PasswordResetConfirmScreen** – visszaigazolás a felhasználónak, hogy e‑mail elküldve.
3. **Deep link kezelés** – `myapp://reset?oobCode=<code>` URI megnyitása → `ResetPasswordScreen`, ahol a felhasználó új jelszót állíthat be.

Az egész flow lokalizált (HU/EN/DE), hozzáférhető WCAG‑AA szinten, és integrál Firebase Auth `sendPasswordResetEmail` / `verifyPasswordResetCode` / `confirmPasswordReset` metódusokkal.

---

## 📂 Érintett/új fájlok

| Fájl                                             | Típus                     | Leírás                                                                 |
| ------------------------------------------------ | ------------------------- | ---------------------------------------------------------------------- |
| `lib/screens/forgot_password_screen.dart`        | Widget                    | E‑mail TextField, Reset CTA                                            |
| `lib/screens/password_reset_confirm_screen.dart` | Widget                    | Info + „Ok” gomb                                                       |
| `lib/screens/reset_password_screen.dart`         | Widget                    | Új jelszó + megerősítés mezők                                          |
| `lib/services/auth_service.dart`                 | Service                   | **Bővítés**: `sendPasswordResetEmail`, `confirmPasswordReset` wrappers |
| `lib/router/router.dart`                         | Router                    | Deep link route `reset-password/:oobCode`                              |
| `test/widgets/forgot_password_flow_test.dart`    | Widget & integration test |                                                                        |
| `.github/workflows/flutter_ci.yaml`              | CI                        | Workflow‑bővítés az új teszthez                                        |

---

## ✅ Feladatlista

1. **ForgotPasswordScreen** – egy TextField, form validáció (érvényes e‑mail), küldés gomb: `authService.sendPasswordResetEmail()`; success → PasswordResetConfirmScreen.
2. **PasswordResetConfirmScreen** – egyszerű info kártya, „Ok” → back to Login.
3. **Deep link route** – GoRouter route `AppRoute.resetPassword` path `/reset-password/:oobCode`.
4. **ResetPasswordScreen** – két Password TextField (új + confirm), real‑time equality ellenőrzés, Submit → `authService.confirmPasswordReset(code, newPassword)`; success → HomeLogged.
5. **AuthService bővítés** – biztonságos wrapper Future\<Either\<AuthFailure, Unit>> típusokkal.
6. **Tesztelés** – mocking Firebase Auth; widget‑ & drive‑test: send mail, open deep link, reset siker.
7. **CI guard** – új teszt futtatása, coverage ≥ 80 %.

---

## 📋 Definition of Done

* E‑mail küldés sikeres, visszajelzés kijelződik.
* Deep link megnyitása új jelszó beállításához működik Android & iOS‑en (test env).
* Új jelszó ≥8 char, 1 szám, 1 nagybetű szabály.
* Lokalizáció HU/EN/DE, accessibility megfelel.
* CI zöld.

---

## 🚧 Korlátozások & Guard‑rails

* `pubspec.yaml` nem bővíthető; csak meglévő Firebase/Auth dependenciák.
* Bináris asset commit tilos.
* Stringek `.arb`‑ba.

---

## 🔄 Output (Codex → Repo)

```yaml
outputs:
  - lib/screens/forgot_password_screen.dart
  - lib/screens/password_reset_confirm_screen.dart
  - lib/screens/reset_password_screen.dart
  - lib/services/auth_service.dart
  - lib/router/router.dart
  - test/widgets/forgot_password_flow_test.dart
  - .github/workflows/flutter_ci.yaml
  - l10n/.arb (kulcs‑update)
```

---

*Ez a vászon rögzíti a Sprint 7 Forgot Password & Reset flow követelményeit.*
