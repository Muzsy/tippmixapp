# RegisterWizard – Step 1 (Account) Implementation – Sprint 2

> **Sprint type**: Feature implementation
> **Estimated effort**: 2 nap

---

## 🎯 Cél (Goal)

A háromlépcsős Regisztrációs varázsló **Step 1 – Account** képernyőjének elkészítése, amely az e‑mail‑cím és a jelszó begyűjtését végzi valós idejű validációval (regex + jelszó erősség) és „Folytatás” gombbal lép tovább a 2. lépésre. A megoldás lokalizált (HU/EN/DE) és hozzáférhetőségi szempontból megfelel a WCAG‑AA szintnek.

---

## 📂 Érintett/új fájlok

| Fájl                                         | Típus                  | Leírás                                                     |
| -------------------------------------------- | ---------------------- | ---------------------------------------------------------- |
| `lib/screens/register_wizard.dart`           | Widget                 | Root `PageView` 3 oldallal (ha még nem létezik)            |
| `lib/screens/register_step1_form.dart`       | Widget                 | E‑mail, jelszó, jelszó‑láthatóság toggle, „Folytatás” CTA  |
| `lib/providers/register_state_notifier.dart` | Riverpod StateNotifier | Wizard state + partial payload tárolása                    |
| `lib/services/auth_service.dart`             | Service                | **Új metódus**: `validateEmailUnique()` (Firestore lookup) |
| `test/widgets/register_step1_form_test.dart` | Widget‑test            | Form‑validáció, Continue navigáció                         |
| `.github/workflows/flutter_ci.yaml`          | CI                     | meglévő workflow‑ban teszt hozzáadása                      |

---

## 📑 Mező‑specifikáció (Step 1)

A Sprint 0 dokumentumból származtatva: e‑mail & jelszó mező, élő validációs szabályok. fileciteturn2file0

---

## ✅ Feladatlista

1. **Wizard skeleton** – Hozd létre (vagy egészítsd ki) a `RegisterWizard` PageView‑t három oldalra tagolva.
2. **Step 1 widget** – `RegisterStep1Form` két TextField‑del, formKey, jelszó erősség mutató.
3. **Valós idejű validáció** – RegEx + min 8 karakter, 1 szám, 1 nagybetű, email RFC 5322.
4. **Continue akció** – Ha a form érvényes, tárold az állapotot `registerStateNotifier.saveStep1()` és csúsztasd a PageView‑t Step 2‑re.
5. **E‑mail egyediség ellenőrzés** – `validateEmailUnique()` a submit előtt (Firestore query, mock Future.delayed a tesztben).
6. **State‑management** – Riverpod Notifier + DTO.
7. **Widget‑ & unit‑tesztek** – happy + error burndown.
8. **CI guard** – lefedettség ≥ 80 %, `flutter analyze` 0 hiba.

---

## 📋 Definition of Done

* Step 1 képernyő hibátlanul működik minden támogatott nyelven.
* Wizard PageView navigáció sima animációval lép Step 2‑re.
* Tesztek lefedettsége ≥ 80 %.
* UI kontraszt ≥ 4.5:1, semanticsLabel minden ikonon.
* Kód megfelel a projekt stílus‑ és guard‑szabályainak.

---

## 🚧 Korlátozások & Guard‑rails

* `PageController` ne legyen globális; használj `AutoDisposeProvider`.
* Stringek kiemelve `.arb`‑ba.
* Semmilyen bináris asset nem kerül a commitba.

---

## 🔄 Output (Codex → Repo)

```yaml
outputs:
  - lib/screens/register_wizard.dart
  - lib/screens/register_step1_form.dart
  - lib/providers/register_state_notifier.dart
  - lib/services/auth_service.dart
  - test/widgets/register_step1_form_test.dart
  - .github/workflows/flutter_ci.yaml
  - l10n/.arb (kulcs‑update)
```

---

*Amint a canvas jóváhagyva, következő lépés a `fill_canvas_register_step1.yaml` generálása, majd `codex run … --dry-run` a Sprint 2‑höz.*
