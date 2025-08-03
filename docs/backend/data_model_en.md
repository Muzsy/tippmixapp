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

- Location: `wallets/{userId}`
- This document is **lazy‑created** by the mobile client on the first bet.
- Later it will be initialised automatically via an **Auth onCreate Cloud Function**.

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
- Odds refreshed on submit via OddsAPI

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

- Stored under `tickets/{userId}/{ticketId}`
- Status updated after match finalization

## 🔜 Planned Models

- `TippCoinLogModel`: logs coin transactions
- `BadgeModel`: for achievements and badge rules
- `LeaderboardEntryModel`: cached leaderboard data
- `FeedEventModel`: recent user activity (for Feed)
