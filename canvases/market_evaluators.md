# 🎯 Function

Introduce a pluggable **Market Evaluator** layer for ticket settlement. Each market (H2H, OU, BTTS, DNB, DC, …) implements the same interface and returns a normalized outcome (`won/lost/void/pending` + `factor` later). Match results are first normalized; tips use coded selections. The ticket wins only if no tip is lost; payout is computed with existing `calcTicketPayout`.

# 🧠 Fejlesztési részletek

* **Files added:** `cloud_functions/src/evaluators/{MarketEvaluator.ts,H2H.ts,index.ts}`.
* **Result normalization:** Extend Api-Football provider result to include `winner` and treat `AET/PEN` as completed.
* **Tip mapping in finalizer:** use `marketKey` and `odds`, keep `selection` from `outcome` for now; evaluator normalizes based on market key.
* **Registry:** `evaluators/index.ts` exposes `getEvaluator(marketKey: string)` with basic aliasing (e.g., `h2h` → `H2H`, `1x2` → `H2H`).
* **Initial scope:** Implement **H2H** evaluator now; others can be added without touching core.

# 🧪 Tesztállapot

* Unit tests to be added per evaluator (starting with `H2H`). Existing payout unit covers combined behavior once results are set.

# 🌍 Lokalizáció

* Evaluators work with coded/normalized fields; UI strings remain in Flutter. Selections are compared against normalized values (`HOME/DRAW/AWAY` or team names) per current data.

# 📎 Kapcsolódások

* **Backend:** `match_finalizer.ts` now calls the evaluator registry to compute each tip result.
* **Services:** `ApiFootballResultProvider.ts` extended with `winner?: string` and broader `completed` logic.
* **Docs:** This canvas complements "Ticket Settlement Engine – Canvas" for long-term extensibility.
