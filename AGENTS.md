# 🧠 AGENTS.md – Codex Agent Configuration (Tipsterino)

This file is **loaded automatically** every time the Codex AI agents start. All generated code must comply with every rule listed below; otherwise the output is **invalid**.

---

## 📦 Project summary

* **Tipsterino** – community‑driven sports‑betting simulator (Flutter + Firebase)
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

---

## 📚 Background documentation (`docs/`)

| File                                             | Purpose                                         |
| ------------------------------------------------ | ----------------------------------------------- |
| `docs/backend/data_model_en.md`                  | UserModel, TicketModel, and TipModel structure  |
| `docs/backend/coin_service_logic_en.md`          | CoinService rules and TippCoin transaction flow |
| `docs/backend/security_rules_en.md`              | Firestore access and mutation security          |
| `docs/frontend/auth_strategy_en.md`              | Authentication logic and UI flow                |
| `docs/frontend/localization_best_practice_en.md` | ARB files and `loc()` usage                     |
| `docs/frontend/theme_rules_en.md`                | Theme handling with FlexColorScheme             |
| `docs/qa/golden_workflow_en.md`                  | Golden testing and a11y compliance              |
| `docs/ci-cd/github_actions_pipeline_en.md`       | GitHub Actions pipeline and CI requirements     |
| `docs/features/leaderboard_logic_en.md`          | Leaderboard structure and update strategy       |
| `docs/features/badge_system_en.md`               | Badge types and achievement evaluation          |
| `docs/features/feed_module_plan_en.md`           | Community activity feed plan and triggers       |
| `docs/features/forum_module_plan_en.md`          | Forum design and thread/post logic              |
| `docs/features/push_notification_strategy_en.md` | FCM setup and planned notification types        |
| `docs/architecture/architecture_overview_en.md`  | Full system layer breakdown                     |

> **Note:** All English docs have `_hu.md` translation pairs for local developers. Codex ignores the Hungarian versions.

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
* **CI pipeline** → `flutter analyze` + `flutter test --concurrency=4` (unit + widget tests, cached & parallel) — no coverage
* **Coverage** → run `flutter test --coverage` only in dedicated CI jobs or when explicitly requested

---

## 🔍 Analyzer / Lint policy

To avoid scanning non‑project code and SDKs, Codex **must** follow these rules when running static analysis:

1. **Run scope**
   Always run:

   ```bash
   flutter analyze lib test integration_test bin tool
   ```

   Do **not** run `flutter analyze .` from repo root.

2. **Options file**
   Respect the root `analysis_options.yaml` and its `analyzer.exclude` globs.

3. **SDK location**
   Flutter SDK **must not live inside the repository** (e.g. `./flutter/`).
   Use an external path (e.g. `$HOME/flutter_sdk` or runner cache) and export it to `PATH`.

4. **CI defaults**

   * Fail on errors, not on infos:

     ```bash
     flutter analyze --no-fatal-infos lib test integration_test bin tool
     ```
   * If the repository has multiple packages, analyze each package’s `lib/` and `test/` explicitly.

---

## Codex defaults

```yaml
target_branch: main
```

If Codex needs to work on a different branch, an explicit instruction in the canvas is required.

---

This file is **binding** for the entire Tipsterino project. Any generated code violating these rules is **invalid** and must be fixed immediately before a pull request can be merged.
