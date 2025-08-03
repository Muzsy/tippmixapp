# 🪙 CoinService Logic (EN)

This document describes the logic and design of the TippCoin virtual currency system in TippmixApp.
TippCoin is used as a betting stake and gamification reward.

---

## 🎯 Purpose

- Virtual in-app currency (no real money)
- Used to place bets (stake)
- Used to reward winning bets
- Used to unlock achievements (planned)

---

## 🧠 Planned Business Logic

### On registration

- `UserModel.tippCoin = 1000`

### On placing a ticket

- A `debitAndCreateTicket()` method runs a Firestore transaction
  that:
  - reads the current balance from `wallets/{uid}.coins`;
  - aborts with `FirebaseException(insufficient_coins)` if balance < stake;
  - subtracts `stake` from both `wallets/{uid}.coins` and `users/{uid}.coins`;
  - writes the new `tickets/{ticketId}` document in the same transaction.

This guarantees atomicity – the user can never end up with a negative
balance and a missing ticket.

### On result finalization

- If ticket.status == `won`:

  - Add `potentialWin` to `user.tippCoin`
- If `lost`, do nothing

---

## 🧾 Technical Plan

- TippCoin changes must be done server-side
- Prefer Firebase Cloud Functions for mutations
- Each transaction should be logged (TippCoinLogModel)

```json
TippCoinLog {
  type: "stake" | "reward",
  amount: int,
  relatedTicketId: string,
  createdAt: timestamp
}
```

- Logs stored under `users/{uid}/coin_logs/`
- UI should show recent changes in profile

---

## ⚠️ Current Status

- `CoinService.debitAndCreateTicket()` implemented for atomic stake
  deduction and ticket creation.
- Balance updates are visible immediately via `users/{uid}.coins` and
  `wallets/{uid}.coins`.
- Logging to `coin_logs` pending implementation.

---

## 🔒 Codex/CI Notes

- All TippCoin updates must be test-covered
- User must never gain/lose coin client-side
- Security rules must prevent unauthorized writes
