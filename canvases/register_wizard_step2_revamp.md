# RegisterWizard – Step 2 (Profile & Consent) Implementation – Sprint 3 *(Final)*

> **Sprint type**: Feature implementation
> **Estimated effort**: 2 nap

---

## 🎯 Cél (Goal)

Összeállítani a Regisztrációs varázsló **Step 2 – Profile & Consent** képernyőjét, ahol a felhasználó megadja *becenevét*, *születési dátumát* és elfogadja a *GDPR‑hozzájárulást*. A képernyő valós idejű mező‑validációt végez és ellenőrzi a becenév egyediségét Firestore‑ban.

---

## 📂 Érintett/új fájlok

| Fájl                                         | Típus    | Leírás                                                      |
| -------------------------------------------- | -------- | ----------------------------------------------------------- |
| `lib/screens/register_step2_form.dart`       | Widget   | Nickname, DatePicker, GDPR checkbox, Back / Continue gombok |
| `lib/providers/register_state_notifier.dart` | Riverpod | Állapot frissítés `saveStep2()`                             |
| `lib/services/auth_service.dart`             | Service  | **Új**: `validateNicknameUnique()` (Firestore query)        |
| `test/widgets/register_step2_form_test.dart` | Test     | Widget‑tesztek validációkra és navigációra                  |
| `.github/workflows/flutter_ci.yaml`          | CI       | Workflow‑bővítés az új tesztekhez                           |

---

## 📑 Mező‑specifikáció *(Sprint 0-ból származik)*

```json
[
  { "field": "nickname",  "label": "Nickname",    "type": "text",   "validation": "required, 3-20 chars, unique" },
  { "field": "birthDate", "label": "Birth date",  "type": "date",   "validation": "required, valid date" },
  { "field": "gdprConsent","label": "GDPR consent","type": "checkbox","validation": "required, must be true" }
]
```

---

## ✅ Feladatlista

1. **Step 2 widget** – `RegisterStep2Form` három mezővel, Back/Continue CTA‑kkal.
2. **Nickname egyediség** – `validateNicknameUnique()` hívás a Continue előtt (mock a tesztben).
3. **GDPR checkbox** – kötelező pipa, Tooltip információval.
4. **Állapotmentés & navigáció** – `registerStateNotifier.saveStep2()`; PageController → Step 3.
5. **Widget‑ & unit‑tesztek** – invalid nickname, GDPR nélküli beküldés, happy path.
6. **CI guard** – coverage ≥ 80 %, `flutter analyze` 0 hiba.

---

## 📋 Definition of Done

* Step 2 működik HU/EN/DE nyelveken.
* Becenév egyediség‑ellenőrzés megbízható (Firestore/mock).
* PageView animáció Step 3‑ra.
* Accessibility megfelel WCAG‑AA‑nak.
* CI zöld (tesztek, lint).

---

## 🚧 Korlátozások & Guard‑rails

* DatePicker Material 3, locale‑aware.
* Nincs globális állapot; csak Riverpod.
* Bináris asset commit tilos.
* Stringek `.arb`‑ba.

---

## 🔄 Output (Codex → Repo)

```yaml
outputs:
  - lib/screens/register_step2_form.dart
  - lib/providers/register_state_notifier.dart
  - lib/services/auth_service.dart
  - test/widgets/register_step2_form_test.dart
  - .github/workflows/flutter_ci.yaml
  - l10n/.arb (kulcs‑update)
```

---

*Ez a vászon az életkor‑ellenőrzést már **nem** tartalmazza; megfelel a legfrissebb követelményeknek.*
