# 🪙 CoinService Logic (EN)

This document describes the logic and design of the TippCoin virtual currency system in TippmixApp.
TippCoin is used as a betting stake and gamification reward.

---

## 🎯 Purpose

* Virtual in-app currency (no real money)
* Used to place bets (stake)
* Used to reward winning bets
* Used to unlock achievements (planned)

---

## 🧠 Planned Business Logic

### On registration

* `UserModel.tippCoin = 1000`

### On placing a ticket

* Subtract stake amount from `user.tippCoin`
* Block submission if not enough balance

### On result finalization

* If ticket.status == `won`:

  * Add `potentialWin` to `user.tippCoin`
* If `lost`, do nothing

---

## 🧾 Technical Plan

* TippCoin changes must be done server-side
* Prefer Firebase Cloud Functions for mutations
* Each transaction should be logged (TippCoinLogModel)

```json
TippCoinLog {
  type: "stake" | "reward",
  amount: int,
  relatedTicketId: string,
  createdAt: timestamp
}
```

* Logs stored under `users/{uid}/coin_logs/`
* UI should show recent changes in profile

---

## ⚠️ Current Status

* Only static value exists in UserModel
* No mutation logic implemented
* No CoinService class or functions yet
* No log collection defined

---

## 🔒 Codex/CI Notes

* All TippCoin updates must be test-covered
* User must never gain/lose coin client-side
* Security rules must prevent unauthorized writes