# 🎯 Function

Modular, extensible ticket settlement engine for multiple betting markets (H2H, OU, BTTS, DNB, DC, EH, AH, CS, …). Each tip is evaluated by a dedicated market plugin producing a normalized result (`WON/LOST/VOID/PUSH/HALF_WIN/HALF_LOSS` + `factor`). Ticket wins only if **no tip is LOST**; payout is `stake × ∏(factor)`.

# 🧠 Fejlesztési részletek

* **Normalized inputs:** API-Football results → `NormalizedResult { period, scores{home,away}, status, completed }`. Completed recognizes `FT/AET/PEN`.
* **Tip schema (Firestore):** `marketKey`, `selection` (coded), `scope` (default `FT`), `odds`, later `status`, `factor` after settlement.
* **MarketEvaluator interface:** per-market plugin with `evaluate(tip, result) -> {status, factor}`. Registry maps `marketKey` → evaluator.
* **Accumulator:** builds ticket status and payout from tip results. `VOID/PUSH` → factor 1.0; Asian quarters produce half factors.
* **Idempotent crediting:** single truth source for coins (prefer `wallets/{uid}.coins` + ledger), guard by `runId`.
* **Today’s P0 code fixes (compatible with current repo):**

  1. `ApiFootballResultProvider` adds `winner` and treats `AET/PEN` as completed.
  2. `match_finalizer`: query root `tickets`, map `marketKey/odds`, and use `userId` instead of `uid`.

# 🧪 Tesztállapot

* **Unit:** evaluator tests per market (edge cases: OU=2.0 push; AH ±0.25 split; ET/PEN scope).
* **Contract:** result normalizer vs API-Football samples.
* **Emulator E2E:** create tickets with known results → run finalizer → assert tips/ticket status + coin change (idempotent rerun).

# 🌍 Lokalizáció

* Tip `selection` values are coded (e.g., `HOME/DRAW/AWAY`, `OVER/UNDER`), UI handles translations; settlement engine stays locale-agnostic.

# 📎 Kapcsolódások

* **Frontend:** `lib/models/{ticket_model.dart, tip_model.dart}`, My Tickets screen queries root `tickets` by `userId`.
* **Backend:** `cloud_functions/src/{match_finalizer.ts, services/ApiFootballResultProvider.ts, tickets/payout.ts}`.
* **Docs:** add `/docs/settlement/*.md` decision tables per market.
