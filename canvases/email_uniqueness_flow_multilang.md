# Auth – Email Egyediség Ellenőrzés + Loader (hu · en · de) – Sprint 7

> **Sprint típusa**: Feature + UX‑finomhangolás
> **Becsült effort**: 1,5 nap (fejlesztés) + 0,5 nap (review / QA)

---

## 🎯 Cél

Mielőtt a felhasználó **„Tovább” / „Regisztrálok”** gombra kattint, a kliens **asynchronous** hívással ellenőrizze, hogy az email‑cím **már létezik‑e** az Auth‑backendben.

* **Eredmény**: azonnali visszajelzés (hu | en | de) –

  * Zöld pipa, ha szabad (✔️ „Ez az email elérhető” / „This email is available” / „Diese E‑Mail ist verfügbar”).
  * Piros hiba, ha foglalt (❌ „Ez az email már foglalt” / „This email is already registered” / „Diese E‑Mail ist bereits vergeben”).
* Pozitív esetben lépjen tovább a jelszó‑lépésre; negatív esetben maradjon a képernyőn.
* **Skeleton / loader** animáció 300 ms‑nál hosszabb válaszidőnél.
* Központi **`AuthRepository.isEmailAvailable(String email)`** service‑hívás.
* Teljes **widget‑ és unit‑teszt lefedettség ≥ 90 %**.

---

## Feladat‑részek

| # | Task                                                                                  | Kimenet                                     |
| - | ------------------------------------------------------------------------------------- | ------------------------------------------- |
| 1 | `AuthRepository` új metódus: `isEmailAvailable` → REST `/auth/email-available?email=` | `lib/services/auth_repository.dart`         |
| 2 | Debounce – `EmailFieldBloc` / `FormCubit` 250 ms                                      | `lib/blocs/email_field_cubit.dart`          |
| 3 | Loader / skeleton (Shimmer) + SnackBar hibákhoz                                       | `lib/ui/widgets/email_loader.dart`          |
| 4 | L10n kulcsok (hu, en, de)                                                             | `lib/l10n/intl_*.arb`                       |
| 5 | Widget‑test – happy/path & already/taken                                              | `test/widgets/email_availability_test.dart` |
| 6 | Unit‑test – repository + debounce util                                                | `test/unit/auth_repository_test.dart`       |

---

## Elfogadási kritériumok

1. **< 200 ms** válaszidőnél nem jelenik meg loader.
2. **> 300 ms** → Skeleton + progress bar.
3. Helyes, lokalizált üzenetek minden státuszban.
4. Hibás hálózat → SnackBar + retry.
5. Minden teszt zöld a CI‑ben (`flutter test && flutter analyze`).

---

## Kockázatok & mitigáció

* **Flaky network** – mock adapter a teszteken.
* **Race‑condition** (gyors gépelés): utolsó kérés számít; használj **`cancelPrevious`** token.
* **Backend 429** – exponential back‑off.

---

© Tippmixapp 2025 – Sprint 7 / Email Uniqueness Flow
