# 🏟️ Tipsterino

![Coverage](./badges/coverage.svg)
[![Coverage Status](https://codecov.io/gh/Muzsy/tippmixapp/branch/main/graph/badge.svg)](https://codecov.io/gh/Muzsy/tippmixapp)
[![Security Rules Coverage](coverage/security_rules_badge.svg)](coverage/security_rules_badge.svg)
[![CI](https://github.com/Muzsy/tippmixapp/actions/workflows/ci.yaml/badge.svg)](https://github.com/Muzsy/tippmixapp/actions/workflows/ci.yaml)

Tipsterino is a modular Flutter application simulating community-based sports betting with virtual currency (no real gambling).
It features a virtual coin economy, real-time odds from [API-Football](https://www.api-football.com/), Firebase backend, and a Codex-based development workflow.

![Login Screen](docs/images/login_revamp_screenshot_v1.png)

---

## 🚀 Features

- **Firebase Authentication** – email/password login and registration
- **TippCoin economy** – stake, reward, and coin logs (CoinService planned)
- **Firestore backend** – stores user, tickets, badge, and leaderboard data
- **API-Football integration** – fetch real-time sports events and odds
- **Bet slip workflow** – add tips and submit tickets
- **Gamification** – badges, leaderboard, community feed (planned)
- **Forum module** – user discussions with threads and replies (planned)
- **Push notifications** – key event alerts via Firebase Cloud Messaging
- **GoRouter navigation** and ARB-based localization with enum keys
- **Theming** – light/dark mode via FlexColorScheme
- **Widget + golden testing** – CI-enforced quality gates

---

## 🧪 Getting Started

1. Install [Flutter](https://docs.flutter.dev/get-started/install) 3.10.0 or later
2. Run: `flutter pub get`
3. Create a `.env` file in project root:

   ```bash
   API_FOOTBALL_KEY=your_api_key_here
   ```

4. Configure Firebase (via `google-services.json`, `GoogleService-Info.plist`)
5. Run the app:

   ```bash
   flutter run
   ```

6. Run tests:

   ```bash
   flutter test
   ```

---

## 🗂️ Repository Structure

| Path           | Contents                                         |
| -------------- | ------------------------------------------------ |
| `lib/`         | Application logic: screens, services, providers  |
| `test/`        | Widget, service, golden, and integration tests   |
| `docs/`        | Technical documentation in English and Hungarian |
| `codex_docs/`  | Codex policy files (`*_en.md`, `*_en.yaml`)      |
| `canvases/`    | AI canvas files describing Codex tasks           |
| `codex/goals/` | YAML workflows for Codex execution               |
| `legacy/`      | Deprecated components (e.g. old AppColors class) |

---

## 📚 Documentation Map

The following files under `docs/` provide detailed insights into the application design.
Only the English versions (`*_en.md`) are used by Codex agents.

### 🧩 Screen-based Documentation

- Guidelines: `docs/guidelines/screen_based_doc_system.md`
- How-to (create a new screen doc): `docs/guidelines/new_screen_howto.md`
- Screen specs live under: `docs/screens/<screen_name>/screen_spec.md`
- Templates: `docs/templates/` (`screen_spec_template.md`, `acceptance_template.md`, `test_plan_template.md`)
- PR rule: any screen change must update its `screen_spec.md` and include initial `qa/acceptance.md` and `qa/test-plan.md` under the screen folder.

### 🔨 Backend Logic

- `docs/backend/data_model_en.md`
- `docs/backend/coin_service_logic_en.md`
- `docs/backend/security_rules_en.md`

### 🎯 Core Features

- `docs/features/leaderboard_logic_en.md`
- `docs/features/badge_system_en.md`
- `docs/features/feed_module_plan_en.md`
- `docs/features/forum_module_plan_en.md`
- `docs/features/push_notification_strategy_en.md`

### 💡 Frontend Behavior

- `docs/frontend/auth_strategy_en.md`
- `docs/frontend/localization_best_practice_en.md`
- `docs/frontend/theme_rules_en.md`

### 📐 Architecture & QA

- `docs/architecture/architecture_overview_en.md`
- `docs/qa/golden_workflow_en.md`
- `docs/ci-cd/github_actions_pipeline_en.md`

All documentation has a `_hu.md` Hungarian version for human readers.

---

## 🎨 Theming

Color and typography styles are defined using `BrandColors` and `FlexColorScheme`.
Avoid using `AppColors` (legacy) – it lives under `legacy/AppColors.dart` for reference only.
All widgets must pull theme colors from `Theme.of(context)`.

---

## 🛡️ CI: Firestore Security Rules

A GitHub Actions workflow runs `scripts/test_firebase_rules.sh` to start the Firebase Emulator
and execute `test/security_rules.test.mjs`. Results are saved to `security_rules_test.log`
and uploaded as a `security-rules-log` artifact.

---

## 👤 Avatar Assets

Place avatar images under `assets/avatar/` manually. Do not commit binary assets to Git.
Default: `assets/avatar/default_avatar.png` if provided.

---

## ☁️ Infrastructure

Terraform includes an optional Slack webhook for alerts. `slack_webhook_url` defaults to an empty string, disabling the notification channel in dev/staging. To enable alerts, pass a non-empty token: `terraform apply -var slack_webhook_url=...`.

---

## Firestore Rules – canonical source & deploy order

- **Canonical source:** `firebase.rules` at repository root.
- `cloud_functions/firestore.rules` is not a deploy source (kept only as reference).
- **Deploy order (GitHub Actions):**
  1. `rm -rf cloud_functions/lib` (stale build guard)
  2. `npm ci && npm run build` under `cloud_functions`
  3. `firebase deploy --only firestore:rules` (from root `firebase.rules`)
  4. `firebase deploy --only functions`

**Note:** the legacy root collection `coin_logs` is **read-only**; clients cannot write there.

For Codex configuration, see: [`AGENTS.md`](./AGENTS.md)

---

## 📴 Offline Playbook

- Env: export `USE_EMULATOR=true USE_MOCK_SCORES=true USE_INLINE_FINALIZER=true API_FOOTBALL_KEY=dummy`
- Start emulators: `pnpm run emu:start` (UI: http://localhost:4000)
- Seed data: `pnpm run seed` and `pnpm run auth:seed`
- Full offline flow: `pnpm run dev:offline:full`
- Flutter run: `flutter run --dart-define=USE_EMULATOR=true`
- Reset/export: `pnpm run emu:reset` / `pnpm run emu:export`
- Tooling: enable Corepack and pnpm (10.15.1): `corepack enable && corepack prepare pnpm@10.15.1 --activate`
- Troubleshooting: Android cleartext enabled; Functions logs in Emulator UI; Auth REST users via `tools/create_test_users.sh`.
