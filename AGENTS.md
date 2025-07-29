# 🧠 AGENTS.md – Codex Agent Configuration (TippmixApp)

This file is **loaded automatically** every time the Codex AI agents start. All generated code must comply with every rule listed below; otherwise the output is **invalid**.

---

## 📦 Project summary

* **TippmixApp** – community‑driven sports‑betting simulator (Flutter + Firebase)
* Virtual **TippCoin** currency (`CoinService` + Cloud Functions)
* Security pop‑up flow (`GuardPopupService`)
* Live odds via **OddsAPI** integration
* Enum‑based **AppLocalizations** system with runtime language switching
* **Codex‑driven** development: *canvas (.md) + steps (.yaml)* is the only accepted workflow

---

## 🧾 Mandatory policy files

The files below live under **`codex_docs/`** and are **auto‑loaded** on every Codex run. A task is considered valid only if it satisfies *all* of these specifications.

### 🔒 Codex policy (`codex_docs/`)

| File                           | Description                                                        |
| ------------------------------ | ------------------------------------------------------------------ |
| `codex_context_en.yaml`        | Global runtime constants, feature flags, CI thresholds             |
| `codex_prompt_builder_en.yaml` | Prompt‑assembly rules for Codex                                    |
| `priority_rules_en.md`         | P0–P3 priority & severity matrix                                   |
| `routing_integrity_en.md`      | Required `GoRouter` patterns and navigation guards                 |
| `localization_logic_en.md`     | i18n architecture and `loc()` wrapper guidelines                   |
| `service_dependencies_en.md`   | Approved Service → Repository → DataSource graph                   |
| `theme_rules_en.md`            | FlexColorScheme & brand‑colour constraints (no hard‑coded colours) |
| `testing_guidelines_en.md`     | Minimum unit/widget/golden/E2E test requirements                   |
| `precommit_checklist_en.md`    | Local checks that must pass **before** pushing                     |

> **Note:** Each policy file has a Hungarian counterpart (`*_hu.*`) for human readers, but **only the English version is consumed by Codex**.

### 📚 Háttérdokumentáció (`docs/`)

| Fájl                                   | Téma                                                             |
| -------------------------------------- | ---------------------------------------------------------------- |
| `theme_management.md`                  | **Hivatalos színséma kezelési dokumentáció**                     |
| `BrandColors_hasznalat.md`             | Brand színek használata `ThemeExtension`‑ön keresztül            |
| `ThemeService_hasznalat.md`            | ThemeService API és perzisztencia‑logika                         |
| `golden_and_accessibility_workflow.md` | Golden + a11y pipeline (jelenleg *inaktív*, lásd döntési doksit) |
| `auth_best_practice.md`                | Firebase Auth irányelvek                                         |
| `localization_best_practice.md`        | ARB struktúra, nyelvi kulcsok                                    |
| `tippmix_app_teljes_adatmodell.md`     | Teljes adatmodell és entitás‑kapcsolatok                         |
| `betting_ticket_data_model.md`         | TicketModel, TipModel részletes leírás                           |
| `coin_logs_cloud_function.md`          | Coin tranzakciók Cloud Function naplózása                        |
| `security_rules_ci.md`                 | Firestore biztonsági szabályok és CI ellenőrzés                  |

> **Megjegyzés:** a golden/a11y pipeline ideiglenesen szünetel, amíg legalább egy fő UI‑képernyő el nem éri az MVP státuszt. A szabályzatok viszont már most is érvényben vannak, és a pipeline aktiválásakor azonnal betartandók.

---

## ⚠️ Global prohibitions

Codex **MUST NOT** create, modify or commit the following files:

* `pubspec.yaml`
* `firebase.json`
* `l10n.yaml`
* `.env`
* **Binary assets** (PNG, JPG, PDF, ZIP, etc.) – these require a manual developer commit

**Further forbidden actions:**

1. Creating a new enum, service, screen or route **without** a prior *canvas (.md) + YAML* definition
2. Hard‑coded strings that bypass localization
3. Hard‑coded colours (hex, RGB, `Colors.*`, etc.) in any widget or `ThemeData`
4. Using `context.go()` or `Navigator.push()` instead of `GoRouter`
5. Merging a PR with a failed CI pipeline – **every** CI step must be green

---

## ✅ Definition of Done (DoD)

* **New screen** → at least *1 widget test* in `test/widgets/`
* **New service** → *unit test* in `test/services/`
* **Localization** → update `hu`, `en`, `de` ARB files and extend `AppLocalizationsKey` enum
* **Theme** → zero hard‑coded colours; linter rule `avoid-hard-coded-colors` passes
* **CI pipeline** → `flutter analyze` + `flutter test --coverage` **all** steps green

---

## Codex defaults

```yaml
target_branch: main
```

If Codex needs to work on a different branch, an explicit instruction in the canvas is required.

---

This file is **binding** for the entire TippmixApp project. Any generated code violating these rules is **invalid** and must be fixed immediately before a pull request can be merged.
