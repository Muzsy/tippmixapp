# 🏟️ TippmixApp

![Coverage](./badges/coverage.svg)
[![Coverage Status](https://codecov.io/gh/Muzsy/tippmixapp/branch/main/graph/badge.svg)](https://codecov.io/gh/Muzsy/tippmixapp)
[![Security Rules Coverage](coverage/security_rules_badge.svg)](coverage/security_rules_badge.svg)
[![CI](https://github.com/Muzsy/tippmixapp/actions/workflows/ci.yaml/badge.svg)](https://github.com/Muzsy/tippmixapp/actions/workflows/ci.yaml)

TippmixApp is a modular Flutter application simulating community-based sports betting.
It features a virtual coin economy, real-time odds from [OddsAPI](https://the-odds-api.com/), Firebase backend, and a Codex-based development workflow.

![Login Screen](docs/images/login_revamp_screenshot_v1.png)

---

## 🚀 Features

- **Firebase Authentication** – email/password login and registration
- **TippCoin economy** – stake, reward, and coin logs (CoinService planned)
- **Firestore backend** – stores user, tickets, badge, and leaderboard data
- **OddsAPI integration** – fetch real-time sports events and odds
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
   ODDS_API_KEY=your_api_key_here
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

Terraform configuration expects a valid Slack webhook. When running `terraform apply`,
pass a non-empty `-var slack_webhook_url=...` value or adjust
`google_monitoring_notification_channel.slack_channel` to `count = 0` to skip creation.

---

For Codex configuration, see: [`AGENTS.md`](./AGENTS.md)
