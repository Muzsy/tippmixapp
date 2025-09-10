# 🧬 Data Model (EN)

This document describes the key data models used in TippmixApp.
The models are implemented in Dart and persisted in Supabase Postgres via PostgREST. Legacy
Firestore paths are noted only where backward compatibility is relevant.

---

## 👤 UserModel

Stores registered user data. **TippCoin balance moved to the WalletModel (see below).**

> ⚠️ **Deprecated field**: `coins` – kept temporarily for backward compatibility. It will be removed after the Cloud Function‑based wallet initialisation rollout.

```dart
UserModel {
  String uid;
  String email;
  String? displayName;
  String? avatarUrl;
  // int tippCoin; // DEPRECATED – see WalletModel
  // planned: badges, leaderboardRank, country
}
```

- Created on registration
- Default `tippCoin = 1000`
- Stored under `users/{uid}`

# 💰 Wallet / Ledger (Supabase)

TippCoin balance and transaction history are stored in tables:

- `coins_ledger(id uuid pk, user_id uuid, type text, delta int, balance_after int, ref_id uuid, created_at timestamptz)`
  - RLS: owner can select; inserts happen via Edge Functions (service role) with idempotencia ref_id alapján.
- Balance derived from latest `balance_after` for a user. No client‑side mutation.

Legacy Firestore wallet/ledger paths are deprecated and only used as fallback in local tests.

## 🎯 TipModel

Represents a single selected outcome (market bet) inside a Ticket.

```dart
TipModel {
  String eventId;      // provider event id
  String eventName;    // human readable (e.g. "Team A – Team B")
  DateTime startTime;  // match commence time
  String sportKey;     // e.g. "soccer"
  String marketKey;    // e.g. "h2h"
  String outcome;      // selected outcome label
  double odds;         // original decimal odds
  TipStatus status;    // won | lost | pending
}
```

- Odds parsing is resilient across providers: accepts `odds`, `odd`, `price`, `decimal`, `decimalOdds`, `o`.
- Status mapping accepts multiple aliases: `status`/`result` (win/won, lose/lost, pending/open), or booleans `won|isWon`, `lost|isLost`, or `settled`.
- Not stored standalone; serialized as part of the `Ticket` document.

## 🎟️ TicketModel

Represents a full bet slip with 1+ tips.

```dart
TicketModel {
  String ticketId;          // UUID in Supabase; legacy Firestore doc.id accepted in compatibility layer
  String userId;
  List<TipModel> tips;      // 1..n tips
  int stake;
  double totalOdd;          // aggregate odds
  double potentialWin;
  String status;            // pending | won | lost | voided
  DateTime createdAt;
  DateTime updatedAt;
}
```

- Tables: `tickets(id uuid pk, user_id uuid, status text, stake numeric, total_odd numeric, potential_win numeric, created_at, updated_at)`
- Items: `ticket_items(id uuid pk, ticket_id uuid fk, fixture_id text, market text, odd numeric, selection text)`
- Status updated by backend (`match_finalizer` + `tickets_payout` Edge Functions)

## 🎁 Bonus rules & state

Global bonus configuration is stored in Supabase `config` table (key/value jsonb). Legacy Firestore
`system_configs/bonus_rules` is deprecated.

```json
BonusRules {
  version: number,
  killSwitch: boolean,
  signup?: { enabled: boolean, amount: number, once: boolean },
  daily?: { enabled: boolean, amount: number, cooldownHours: number, maxPerDay?: number }
}
```

Per‑user bonus progress is derived from `coins_ledger` entries of type `daily_bonus` or from
server‑maintained state (if introduced later). Legacy `users/{uid}/bonus_state` is deprecated.

```json
BonusState {
  signupClaimed?: boolean,
  lastDailyClaimAt?: timestamp,
  dailyCooldownUntil?: timestamp,
  lastAppliedVersion?: number,
  lock?: { active: boolean, expiresAt: timestamp | null }
}
```

## 🏷️ Badges, Followers & Friend Requests (Supabase)

- `badges(user_id uuid, key text, created_at)` – RLS: owner can read/insert own
- `followers(user_id uuid, follower_id uuid, created_at)` – public read, owner insert/delete
- `friend_requests(id uuid, to_uid uuid, from_uid uuid, accepted bool, created_at)` – to_uid can read/update; from_uid can insert

## 🗑️ Deprecated Models

- Firestore `users/{uid}/wallet`, `users/{uid}/ledger`, `system_configs/bonus_rules`
- `TippCoinLogModel`: replaced by `coins_ledger`

## 📘 Changelog

- 2025-08-20: Documented dual-write wallet/ledger paths and onCreate seeding.
- 2025-08-22: Added BonusRules and BonusState models for Bonus Engine.
- 2025-08-23: Removed legacy `wallets/{userId}` path from WalletModel.
- 2025-08-30: Updated TipModel and TicketModel to current fields (status enum, robust odds parsing, totals, updatedAt).
