# Auth – Security Hardening (Password Breach + reCAPTCHA v3) – Sprint 9

> **Sprint típusa**: Biztonsági bővítés + refaktor
> **Becsült effort**: 2,5 nap (fejlesztés) + 0,5 nap (review / QA)

---

## 🎯 Cél

Erősítsük meg az email + jelszó alapú autentikációt az alábbiakkal **háromnyelvű lokalizációval (hu, en, de)**:

1. **Have I Been Pwned (HIBP) jelszó‑szivárgás ellenőrzés** a regisztrációs űrlapon (k‑anonymity / hash‑prefix lekérdezés).
2. **Google reCAPTCHA v3** védelem bot‑regisztráció ellen (Android, iOS, Web).
3. **Központi AuthException‑mapper**, amely konzisztensen, lokalizáltan jeleníti meg a hibákat.

A fenti pontokhoz teljes unit‑/widget‑/integrációs teszt‑lefedettség szükséges, CI‑ben ≥ 80 %. 

---

## Kimenetek

| Fájl / Modul                                  | Új / Módosított | Rövid leírás                                        |
| --------------------------------------------- | --------------- | --------------------------------------------------- |
| `lib/services/hibp_service.dart`              | **Új**          | SHA‑1 prefix lekérdezés + response parser           |
| `lib/services/recaptcha_service.dart`         | **Új**          | Platform‑függő reCAPTCHA wrapper                    |
| `lib/ui/widgets/password_strength_field.dart` | Mód             | "Lehet, hogy ez a jelszó kiszivárgott" üzenet       |
| `lib/l10n/intl_*.arb`                         | Mód             | Új kulcsok: `pwnedWarning`, `recaptchaFailed`, stb. |
| `test/services/hibp_service_test.dart`        | **Új**          | Mockolt HIBP válaszok                               |
| `integration_test/recaptcha_flow_test.dart`   | **Új**          | Happy‑path + failure                                |

---

## Elfogadási kritériumok

* **Pwned jelszó** esetén a felhasználó figyelmeztető toast‑ot kap, de nem tiltjuk le a "Tovább" gombot (UX‑kutatás szerint).
* reCAPTCHA sikertelen → a regisztrációs request meg sem indul.
* A hibák mindhárom nyelven jelennek meg, CI l10n‑check zöld.
* `flutter test`, `flutter analyze` és `flutter integration_test` mind zöld.
* iOS + Android + Web build pipelineon átmegy.

---

## Jegyzetek

* HIBP API‑kulcsot a `secrets.GITHUB_HIBP_KEY`‑ben tároljuk; mock‑kulcs a CI‑hez.
* reCAPTCHA v3‑hoz Firebase App Check plugin is használható (kisebb platform‑patch, gyorsabb setup).
* Exception‑mapper kiterjeszti a meglévő `AuthErrorExtensions`‐t.
