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

- `CoinService.credit(uid, potentialWin, ticketId)` runs a Firestore transaction that:
  - checks `wallets/{uid}/ledger/{ticketId}` and exits if already exists (idempotent);
  - increments `wallets/{uid}.balance`;
  - writes ledger entry `{ amount, type: 'win', createdAt }`.
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
  wallets/{uid}
    balance: number
    updatedAt: timestamp
    ledger/{ticketId}
      amount: number
      type: 'bet' | 'win'
      createdAt: timestamp
  ```
- Logs stored under `users/{uid}/coin_logs/`
- UI should show recent changes in profile

---

## ⚠️ Current Status

- `CoinService.transact()` ensures idempotent balance changes and ledger entries.
- `CoinService.debitAndCreateTicket()` handles atomic stake deduction with ticket creation.
- Wallet balance stored at `wallets/{uid}.balance` updates immediately.
- Logging to `coin_logs` pending implementation.

---

## 🔒 Codex/CI Notes

- All TippCoin updates must be test-covered
- User must never gain/lose coin client-side
- Security rules must prevent unauthorized writes
