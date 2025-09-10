# 🪙 CoinService Logic (EN)

This document describes the logic and design of the TippCoin virtual currency system in TippmixApp.
TippCoin is used as a betting stake and gamification reward.
Implementation uses Supabase (Postgres + Edge Functions). Legacy Firestore notes are kept only
for context.

---

## 🎯 Purpose

- Virtual in-app currency (no real money)
- Used to place bets (stake)
- Used to reward winning bets
- Used to unlock achievements (planned)

---

## 🧠 Planned Business Logic

### On registration

- Profiles are upserted in `profiles(id, nickname, avatar_url)`
- Optional signup bonus may be credited via an Edge Function (future)

### On placing a ticket

- Client inserts a row into `tickets` and its `ticket_items`
- Then invokes Edge Function `coin_trx` with `{ delta: -stake, type: 'bet_stake', ref_id: ticketId }`
- The function reads latest balance from `coins_ledger`, computes `balance_after`, and inserts a new
  row with idempotent `ref_id`
- Errors are surfaced to the client; compensation logic can delete the just‑created ticket if needed

This keeps the client free of any direct wallet writes.

### On result finalization

- Backend jobs (`match_finalizer`, `tickets_payout`) compute outcomes and credit potential wins by
  inserting rows into `coins_ledger` (type `bet_win`, `ref_id = ticketId`), idempotensen

### Daily bonus credit

- Users can claim a bonus via `claim_daily_bonus` Edge Function, which checks `coins_ledger` for a
  same‑day entry and credits e.g. **50** coins if allowed
- Deterministic `ref_id` (e.g., `bonus:daily:YYYYMMDD`) ensures idempotency

---

## 🧾 Technical Plan

- TippCoin changes happen server‑side via Edge Functions
- Client never modifies balance directly
- Each transaction is logged in `coins_ledger` with idempotent `ref_id`

```json
TippCoinLog {
  type: "stake" | "reward",
  amount: int,
  relatedTicketId: string,
  createdAt: timestamp
}
```

Tables:

```
coins_ledger (
  id uuid pk default gen_random_uuid(),
  user_id uuid not null,
  type text not null,
  delta int not null,
  balance_after int not null,
  ref_id uuid,
  created_at timestamptz default now()
)
```

---

## ⚠️ Current Status

- Client hívások: `SupabaseCoinService`, EdgeFn: `coin_trx`, `claim_daily_bonus`
- Forrás: `coins_ledger`, kliens fallback nincs (csak teszthelyzetekben)
- Bonus szabályok: `config` tábla (jsonb), edge‑oldali ellenőrzéssel

---

## 🔒 Codex/CI Notes

- All TippCoin updates must be test‑covered
- User must never gain/lose coin client‑side
- RLS must prevent unauthorized reads/writes; server role used only in EdgeFn

## 📘 Changelog

- 2025-08-20: Documented dual-write to user-centric wallet & ledger and registration seeding.
- 2025-08-20: Updated to single SoT (`users/{uid}/wallet/main` + `users/{uid}/ledger`) and removed legacy writes.
- 2025-08-20: Removed client-side wallet writes; `coin_trx` handles all balance changes.
- 2025-08-21: Added daily bonus credit via CoinService with deterministic `refId`.
- 2025-08-22: Introduced ledger `checksum` field and callable `claim_daily_bonus`; signup bonus handled on user creation.
- 2025-10-02: Added paginated daily bonus with structured logging and ledger type+createdAt index.
- 2025-10-03: Enforced ledger pre-check to skip wallet increment when refId already exists.
- 2025-09-10: Migrated flow to Supabase (`coins_ledger` + Edge Functions)
