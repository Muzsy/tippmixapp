# 📘 Documentation Overview / Dokumentációs áttekintés

This directory contains the full technical documentation of the **TippmixApp** project.
Each file exists in both **English** (`_en.md`) and **Hungarian** (`_hu.md`) versions.
English is the **canonical source** for AI tools (e.g. Codex). Hungarian is for human readers.

Ez a mappa tartalmazza a **TippmixApp** projekt teljes technikai dokumentációját.
Minden fájl elérhető **angol** (`_en.md`) és **magyar** (`_hu.md`) nyelven.
Az angol a **hivatalos forrás** az AI-eszközök (pl. Codex) számára, a magyar az emberi olvasóknak készült.

## 🗂️ File Structure / Fájlstruktúra

| Topic / Téma                    | English                            | Magyar                             |
| ------------------------------- | ---------------------------------- | ---------------------------------- |
| Architecture Overview           | `architecture_overview_en.md`      | `architecture_overview_hu.md`      |
| Data Model                      | `data_model_en.md`                 | `data_model_hu.md`                 |
| Authentication Strategy         | `auth_strategy_en.md`              | `auth_strategy_hu.md`              |
| Localization Best Practices     | `localization_best_practice_en.md` | `localization_best_practice_hu.md` |
| Theme Rules & Branding          | `theme_rules_en.md`                | `theme_rules_hu.md`                |
| Coin Service Logic              | `coin_service_logic_en.md`         | `coin_service_logic_hu.md`         |
| Environment Config Loader       | `env_config_en.md`                 | `env_config_hu.md`                 |
| Quota Watcher Alert             | `quota_watcher_en.md`              | `quota_watcher_hu.md`              |
| Leaderboard Logic               | `leaderboard_logic_en.md`          | `leaderboard_logic_hu.md`          |
| Badge System                    | `badge_system_en.md`               | `badge_system_hu.md`               |
| Feed Module Plan                | `feed_module_plan_en.md`           | `feed_module_plan_hu.md`           |
| Forum Module Plan               | `forum_module_plan_en.md`          | `forum_module_plan_hu.md`          |
| Push Notification Strategy      | `push_notification_strategy_en.md` | `push_notification_strategy_hu.md` |
| Pub/Sub Topics                  | `pubsub_topics_en.md`              | `pubsub_topics_hu.md`              |
| Result Provider Service         | `result_provider_en.md`            | `result_provider_hu.md`            |
| match_finalizer Function        | `match_finalizer_en.md`           | `match_finalizer_hu.md`           |
| Golden Testing & Accessibility  | `golden_workflow_en.md`            | `golden_workflow_hu.md`            |
| Security Rules & Access Control | `security_rules_en.md`             | `security_rules_hu.md`             |
| CI/CD Pipeline                  | `github_actions_pipeline_en.md`    | `github_actions_pipeline_hu.md`    |

## 📌 Notes / Megjegyzések

- All future documents must follow the naming: `[topic]_en.md` and `[topic]_hu.md`
- Codex only loads the **EN** files, the `_hu.md` versions are for human review only.
- Minden új dokumentumot ebben a struktúrában kell elhelyezni.
- A fordításokat a Git commit hook ellenőrzi (szinkronban vannak-e).

## 🧭 Legacy / Örökség

Old sprint reports and audits have been moved to `/docs/legacy/`.
Régi sprint riportokat és auditokat a `/docs/legacy/` mappába helyeztünk át.

---

For global rules, see: [AGENTS.md](../AGENTS.md)
Általános szabályok: lásd [AGENTS.md](../AGENTS.md)
