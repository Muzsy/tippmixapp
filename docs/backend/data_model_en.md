# 🧬 Data Model (EN)

This document describes the key data models used in TippmixApp.
The models are implemented in Dart and stored in Firestore.

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

# 💰 WalletModel (NEW)

Stores TippCoin balance per user.

```dart
WalletModel {
  String userId;   // same as auth.uid
  int coins;       // Current TippCoin balance
  Timestamp createdAt;
}
```

- Location: `users/{userId}/wallet` (source of truth)
- This document is **lazy‑created** by the mobile client on the first bet.
- An Auth onCreate Cloud Function now seeds both locations with a 50 coin balance.
- Ledger entries mirror to `users/{userId}/ledger/{entryId}` for audit.

## 🎯 TipModel

Represents a single selected outcome (market bet).

```dart
TipModel {
  String matchId;
  String event;
  String market;
  String outcome;
  double odds;
}
```

- Attached to a ticket (not stored standalone)
- Odds refreshed on submit via API-Football

## 🎟️ TicketModel

Represents a full bet slip with 1+ tips.

```dart
TicketModel {
  String ticketId;
  String userId;
  List<TipModel> tips;
  int stake;
  double potentialWin;
  String status; // pending, won, lost
  Timestamp createdAt;
}
```

- Stored under `users/{userId}/tickets/{ticketId}`
- Status updated after match finalization

## 🎁 Bonus rules & state

Global bonus configuration is stored in `system_configs/bonus_rules`.

```json
BonusRules {
  version: number,
  killSwitch: boolean,
  signup?: { enabled: boolean, amount: number, once: boolean },
  daily?: { enabled: boolean, amount: number, cooldownHours: number, maxPerDay?: number }
}
```

Per-user bonus progress lives at `users/{uid}/bonus_state`.

```json
BonusState {
  signupClaimed?: boolean,
  lastDailyClaimAt?: timestamp,
  dailyCooldownUntil?: timestamp,
  lastAppliedVersion?: number,
  lock?: { active: boolean, expiresAt: timestamp | null }
}
```

## 🔜 Planned Models

- `BadgeModel`: for achievements and badge rules
- `LeaderboardEntryModel`: cached leaderboard data
- `FeedEventModel`: recent user activity (for Feed)

## 🗑️ Deprecated Models

- `TippCoinLogModel`: replaced by per-user ledger entries under `users/{uid}/ledger`

## 📘 Changelog

- 2025-08-20: Documented dual-write wallet/ledger paths and onCreate seeding.
- 2025-08-22: Added BonusRules and BonusState models for Bonus Engine.
- 2025-08-23: Removed legacy `wallets/{userId}` path from WalletModel.
