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

- `debitAndCreateTicket()` first writes the ticket to
  `users/{uid}/tickets/{ticketId}`.
- It then calls the `coin_trx` Cloud Function with
  `{ amount: stake, type: 'debit', reason: 'bet', transactionId: ticketId }`.
- The Cloud Function deducts the balance in
  `users/{uid}/wallet.coins` and appends a ledger entry
  `users/{uid}/ledger/{ticketId}` atomically.
- If the function call fails, the client deletes the created ticket
  (compensation) and rethrows the error.

This keeps the client free of any direct wallet writes.

### On result finalization

- `CoinService.credit(uid, potentialWin, ticketId)` runs a Firestore transaction that:
  - checks `users/{uid}/ledger/{ticketId}` and exits if already exists (idempotent);
  - increments `users/{uid}/wallet.coins` with `FieldValue.increment`;
  - writes ledger entry `{ userId, amount, type: 'win', refId: ticketId, source: 'coin_trx', createdAt }`.
- `CoinService.debit(uid, stake, ticketId)` performs the same flow with a negative amount and `type: 'bet'`.

### Daily bonus credit

- The scheduled `daily_bonus` Cloud Function grants **50** coins to each user.
- Users can also claim a bonus via the `claim_daily_bonus` callable, which reads `system_configs/bonus_rules` and credits the wallet with `CoinService.credit(uid, amount, refId, 'daily_bonus', t, before)`.
- Credit operations use a deterministic `refId` (`bonus:daily:YYYYMMDD`) to ensure idempotency.
- The scheduled job paginates users in batches of 200 and logs progress via `firebase-functions/logger`.

---

## 🧾 Technical Plan

- TippCoin changes must be done server-side via Cloud Functions.
- Client code never modifies `users/{uid}/wallet` or `users/{uid}/ledger` directly.
- Each transaction is logged in the ledger with an idempotent `refId`.
- Composite Firestore index: `collectionGroup('ledger')` on `(type ASC, createdAt DESC)`.

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
    checksum: string // SHA1(uid:type:refId:amount)
    createdAt: timestamp
  ```
- Legacy path `wallets/*` remains read-only; `coin_logs/*` has been removed
- UI should show recent changes in profile

---

## ⚠️ Current Status

- `CoinService.debitCoin` and `creditCoin` only invoke `coin_trx`; all wallet updates happen server-side.
- `CoinService.debitAndCreateTicket()` creates the ticket then triggers `coin_trx` debit.
- Wallet balance stored at `users/{uid}/wallet.coins` is treated as source of truth and updated by Cloud Functions.
- `coin_logs` collection removed; per-user ledger is the sole transaction log.
- Signup bonus and daily bonus claims are governed by `system_configs/bonus_rules`.

---

## 🔒 Codex/CI Notes

- All TippCoin updates must be test-covered
- User must never gain/lose coin client-side
- Security rules must prevent unauthorized writes

## 📘 Changelog

- 2025-08-20: Documented dual-write to user-centric wallet & ledger and registration seeding.
- 2025-08-20: Updated to single SoT (`users/{uid}/wallet` + `users/{uid}/ledger`) and removed legacy writes.
- 2025-08-20: Removed client-side wallet writes; `coin_trx` handles all balance changes.
- 2025-08-21: Added daily bonus credit via CoinService with deterministic `refId`.
- 2025-08-22: Introduced ledger `checksum` field and callable `claim_daily_bonus`; signup bonus handled on user creation.
- 2025-10-02: Added paginated daily bonus with structured logging and ledger type+createdAt index.
