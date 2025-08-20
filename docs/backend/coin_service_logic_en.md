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

- Cloud Function seeds `users/{uid}/wallet` with **50** coins (user doc has no `coins` field)

### On placing a ticket

- A `debitAndCreateTicket()` method runs a Firestore transaction
  that:
  - reads the current balance from `users/{uid}/wallet.coins`;
  - aborts with `FirebaseException(insufficient_coins)` if balance < stake;
  - subtracts `stake` from `users/{uid}/wallet.coins`;
  - writes an audit entry `users/{uid}/ledger/{ticketId}`;
  - writes the new `tickets/{ticketId}` document in the same transaction.

This guarantees atomicity – the user can never end up with a negative
balance and a missing ticket.

### On result finalization

- `CoinService.credit(uid, potentialWin, ticketId)` runs a Firestore transaction that:
  - checks `users/{uid}/ledger/{ticketId}` and exits if already exists (idempotent);
  - increments `users/{uid}/wallet.coins` with `FieldValue.increment`;
  - writes ledger entry `{ userId, amount, type: 'win', refId: ticketId, source: 'coin_trx', createdAt }`.
- `CoinService.debit(uid, stake, ticketId)` performs the same flow with a negative amount and `type: 'bet'`.

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

- Wallet structure:

  ```
  users/{uid}/wallet
    coins: number
    updatedAt: timestamp
  users/{uid}/ledger/{ticketId}
    userId: string
    amount: number
    type: 'bet' | 'win'
    refId: string
    source: 'coin_trx' | 'log_coin'
    createdAt: timestamp
  ```
- Legacy paths `wallets/*` and `coin_logs/*` remain for read-only access
- UI should show recent changes in profile

---

## ⚠️ Current Status

- `CoinService.transact()` ensures idempotent balance changes and ledger entries in the user-centric SoT.
- `CoinService.debitAndCreateTicket()` handles atomic stake deduction with ticket creation.
- Wallet balance stored at `users/{uid}/wallet.coins` updates immediately.
- `coin_logs` collection deprecated in favor of per-user ledger.

---

## 🔒 Codex/CI Notes

- All TippCoin updates must be test-covered
- User must never gain/lose coin client-side
- Security rules must prevent unauthorized writes

## 📘 Changelog

- 2025-08-20: Documented dual-write to user-centric wallet & ledger and registration seeding.
- 2025-08-20: Updated to single SoT (`users/{uid}/wallet` + `users/{uid}/ledger`) and removed legacy writes.
