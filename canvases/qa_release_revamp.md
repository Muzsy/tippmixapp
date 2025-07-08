# QA, Accessibility & Release – Sprint 8 (Final)

> **Sprint type**: QA / Release
> **Estimated effort**: 1 nap

---

## 🎯 Cél (Goal)

Lezárni a Login & Register revampot teljes minőségbiztosítással, akadálymentesítéssel és publikációval:

1. **WCAG‑AA audit** – Kontraszt, semanticsLabel, TalkBack/VoiceOver teszt.
2. **Lokalizáció véglegesítés** – HU/EN/DE .arb szinkron, nem használt kulcsok törlése, `flutter gen-l10n`.
3. **E‑mail‑verifikáció flow** – `sendEmailVerification()` regisztráció végén + „E-mail megerősítve?” polling snackbar.
4. **AGENTS.md** – új `GuardPopupService` dependency rögzítése.
5. **CI token switch** – staging → production token a `codex_context.yaml`‑ban.
6. **CI pipeline hardening** – extra accessibility linter (`flutter_a11y`), `flutter build appbundle` + iOS IPA TestFlight step.
7. **Release‑note & semver bump** – `CHANGELOG.md` + `pubspec.yaml version` → `1.4.0` (példa).
8. **Git tag & push** – `v1.4.0-login_revamp`.
9. **Stakeholder UAT** – `docs/uat_checklist_login_register_revamp.md` létrehozása, aláírás mezőkkel.

---

## 📂 Érintett/új fájlok

| Fájl                                          | Művelet    | Leírás                                                |
| --------------------------------------------- | ---------- | ----------------------------------------------------- |
| `lib/**`                                      | **MODIFY** | semanticsLabel, contrast fixek (auto‑generated diffs) |
| `lib/l10n/*.arb`                              | **MODIFY** | végleges kulcslista & fordítások                      |
| `lib/services/auth_service.dart`              | **MODIFY** | `sendEmailVerification()` wrapper + polling           |
| `AGENTS.md`                                   | **UPDATE** | `GuardPopupService` regisztrálása                     |
| `codex_docs/codex_context.yaml`               | **UPDATE** | production CI token                                   |
| `.github/workflows/flutter_ci.yaml`           | **UPDATE** | a11y linter + build‑release lépések                   |
| `CHANGELOG.md`                                | **UPDATE** | v1.4.0 bejegyzés                                      |
| `docs/uat_checklist_login_register_revamp.md` | **ADD**    | UAT ellenőrzőlista                                    |

---

## ✅ Feladatlista

1. **Automata WCAG audit** – futtasd `flutter_a11y`; javítsd kontraszt és semanticsLabel hibákat.
2. **Lokalizáció sync** – export‑import táblázat, manuális HU/EN/DE finomítás, `flutter gen-l10n`.
3. **E‑mail‑verifikáció** – Regisztráció után küldés; Snackbar „Megerősítetted már?”; poll `FirebaseAuth.user.reload()`; max 3 perc timeout.
4. **AGENTS & Context** – frissítsd `AGENTS.md` + CI token.
5. **CI pipeline** – Add steps: `flutter_a11y`, `flutter build appbundle` (Android), `flutter build ipa --no‑codesign` (iOS).
6. **Release artefacts** – publish Beta buildek (CI only, no binary commit).
7. **CHANGELOG & Tag** – automatikus generálás (`git tag -a v1.4.0`).
8. **UAT checklist** – Markdown táblázat, checkboxok; Product Owner aláírás.

---

## 📋 Definition of Done

* Minden WCAG‑AA hibajelentés 0.
* Lokalizáció teljes, `flutter gen-l10n` sikeres.
* E‑mail‑verifikáció flow működik sandbox Firebase‑projektben.
* CI pipeline mindhárom platform‑lépésre zöld.
* CHANGELOG, Git tag, UAT checklist jóváhagyva.

---

## 🚧 Korlátozások & Guard‑rails

* **No binary commits** – release buildek csak Artefact store‑ba mennek.
* `pubspec.yaml` csak version & changelog link frissül.
* Új dependency nem adható hozzá (flutter\_a11y már jelen).

---

## 🔄 Output (Codex → Repo)

```yaml
outputs:
  - modify: [lib/**, lib/l10n/*.arb, lib/services/auth_service.dart, AGENTS.md, codex_docs/codex_context.yaml, .github/workflows/flutter_ci.yaml, CHANGELOG.md]
  - add: [docs/uat_checklist_login_register_revamp.md]
```

---

*Ez a vászon rögzíti a végső QA & Release sprint (Sprint 8) követelményeit.*
