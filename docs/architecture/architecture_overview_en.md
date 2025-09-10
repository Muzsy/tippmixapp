# 🏛️ Architecture Overview (EN)

This document provides a high-level overview of the **TippmixApp** architecture.
It outlines the core modules, layer responsibilities, and cross-cutting concerns.

## 🧱 Main Components

### 1. Flutter Frontend

- Built with **Material 3** design and **Riverpod** state management.
- Uses **GoRouter** (ShellRoute) for navigation with AppBar + BottomNavBar layout.
- Localized using `flutter_localizations` with `.arb` files.
- Core screens: Home, Profile, MyTickets, Login, Register, Settings (WIP).

### 2. Supabase Backend

- **Auth (GoTrue)** – email/password (OAuth optional), session handling
- **PostgREST** – `profiles`, `forum_threads`, `forum_posts`, `votes`, `tickets`, `ticket_items`, `coins_ledger`, `badges`, `followers`, `friend_requests`
- **Edge Functions (Deno)** – `coin_trx`, `claim_daily_bonus`, `match_finalizer`, `tickets_payout`
- **Realtime** – table changes (forum, tickets)
- **Storage** – avatars bucket, signed URLs
- **Cron (pg_cron/Scheduler)** – scheduled invocations of Edge Functions

### 3. External API

- Integrates with **API-Football** to fetch real-time match odds.
- HTTP calls made via custom `ApiFootballService` class.
- API key handling currently static; planned migration to `.env` file.

### 4. Edge Functions (Deno/TypeScript)

- `match_finalizer` and `tickets_payout` manage results & payouts
- `coin_trx` and `claim_daily_bonus` implement TippCoin flows (idempotent)

---

## 🧭 Layered View

```
┌──────────────────────────────┐
│          User (UI)          │ ← Home, Profile, Login...
└────────────┬────────────────┘
             ↓
┌────────────┴────────────┐
│  Presentation Layer     │ ← Widgets, ViewModels
└────────────┬────────────┘
             ↓
┌────────────┴────────────┐
│   Domain Layer          │ ← Services, Business logic
└────────────┬────────────┘
             ↓
┌────────────┴────────────┐
│   Data Layer            │ ← Supabase (PostgREST/Realtime/Storage), API‑Football, SharedPrefs
└─────────────────────────┘
```

---

## 🔄 Cross-cutting Concepts

- **Localization** – via `AppLocalizations`, context-aware `loc()` wrappers.
- **Theming** – powered by `FlexColorScheme`, dark/light mode ready.
- **Security Rules** – enforced on Firestore level, not yet finalized.
- **Testing** – widget tests present; need expansion to services, integration.
- **Codex Integration** – via canvases + YAML rules (Codex consumes `_en.md`).

---

## 📌 Planned Improvements

- Move API key handling to `flutter_dotenv`
- Implement Cloud Functions for odds sync + coin logic
- Add CI pipeline with `flutter test`, `markdownlint`, link-checker
- Complete Settings UI (language + theme)

---

See also: `data_model_en.md`, `auth_strategy_en.md`, `coin_service_logic_en.md`
