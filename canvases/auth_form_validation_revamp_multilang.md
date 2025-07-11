# Auth – Email + Jelszó Form Validáció (Revamp + 3‑nyelvű l10n) – Sprint 6

> **Sprint típusa**: Refaktor + feature‑bővítés
> **Becsült effort**: 2 nap (fejlesztés) + 0,5 nap (review / QA)

---

## 🎯 Cél

A bejelentkezési (**LoginForm**) és regisztrációs első lépés (**RegisterStep1Form**) űrlap **valósidejű, felhasználóbarát** validációt kapjon **háromnyelvű lokalizációval (hu, en, de)**:

* RFC 5322‑kompatibilis email‑formátum ellenőrzés.
* Erős jelszó‑szabályok (≥ 8 karakter, kis‑ és nagybetű, szám, speciális).
* Valósidejű hiba‑/segítő üzenetek, melyek azonnal frissülnek gépelés közben.
* Jelszó‑erősség sáv + „Show/Hide” ikon.
* A „Tovább” gomb csak akkor aktív, ha minden mező érvényes.
* **Minden user‑facing string** a `l10n/arb` mappából töltődik be magyar, angol és német nyelven.
* Automated widget‑ és unit‑tesztek (coverage ≥ 80 %).

---

## 🌍 Lokalizáció – Követelmények

| Nyelv  | Fájlnév               | Példa‑kulcs / érték                                                   |
| ------ | --------------------- | --------------------------------------------------------------------- |
| Magyar | `lib/l10n/app_hu.arb` | "validator.email.invalid" → „Érvénytelen email‑cím”                   |
| Angol  | `lib/l10n/app_en.arb` | "validator.password.short" → "Password must be at least 8 characters" |
| Német  | `lib/l10n/app_de.arb` | "password.strength.weak" → "Schwaches Passwort"                       |

* A kulcs‑név konvenció marad: `category.section.key`.
* **Fallback**: ha hiányzó fordítás, az angol érték jelenjen meg (Flutter i18n fallback).
* Teszt: futtass `flutter gen-l10n` → nem lehet hiányzó kulcs.

---

## 🎫 Acceptance Criteria

1. **Email‑validátor**: rossz formátum esetén hiba‑üzenet a három nyelv bármelyikén.
2. **Jelszó‑validátor**: minden szabálysértést lokalizált chip‑listában jelenít meg.
3. **Password strength bar**: "Weak / Medium / Strong" felirat lokalizálva.
4. **Live‑validation** demó videó a PR‑ban (⇠ QA‑team kérte).
5. **Teszt‑suites** zölden futnak: `flutter analyze`, `flutter test`, `flutter test --coverage` → 80 %+.
6. **ARB‑fájlok** teljesek, linter nem jelez hiányzó kulcsot.

---

## 🛠️ Tech notes

* Használd a `Formz` csomagot a validator modellekre.
* `Intl` / `flutter_localizations` már be van húzva a projektben.
* A `l10n.yaml` -ben állítsd `arb-dir: lib/l10n` és `untranslated-messages-file: l10n_missing.txt`.
* **Codegen**: `flutter gen-l10n` a CI Pipeline Step #2‑ben.
* Bővítsd a `test/support/l10n` mockot, hogy mindhárom nyelvet kezelje.

---

## ⛔️ Out of scope

* Szerver‑oldali email‑egyediség ellenőrzés (külön sprint).
* E‑mail domain‑black‑/whitelist.
* Social‑login flow‑k.

---

## 🗂 Fájlérintés

```
lib/
 ├─ features/auth/presentation/widgets/
 │   ├─ login_form.dart
 │   └─ register_step1_form.dart
 ├─ l10n/
 │   ├─ app_en.arb
 │   ├─ app_hu.arb
 │   └─ app_de.arb
 test/
 ├─ widgets/
 ├─ unit/
 └─ support/
```

---

## 📅 Timeline

1. **D‑0 Délelőtt** – Validator modellek + unit‑tesztek.
2. **D‑0 Délután** – Widget‑refaktor, l10n kulcsok hozzáadása.
3. **D‑1 Délelőtt** – CI zöldre, hiányzó fordítások, strength bar.
4. **D‑1 Délután** – QA rövid demo‑video, PR feladás.

---

## 💬 Reviewer Checklist

* [ ] Bemeneti mezők validációja fail/success state‑tel.
* [ ] 3 nyelv mindegyikén helyes hiba‑üzenetek.
* [ ] ARB‑kulcs‑következetesség.
* [ ] Unit‑ & widget‑teszt lefedi a hibautakat.
* [ ] Kódstílus (`flutter analyze`) tiszta.
