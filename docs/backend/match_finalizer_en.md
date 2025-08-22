version: "2025-10-02"
last_updated_by: codex-bot
depends_on: []

# 🧮 match_finalizer Cloud Function (EN)

Background worker processing `result-check` Pub/Sub messages. Its responsibilities:

1. Decode job type (`kickoff-tracker`, `result-poller`, `final-sweep`).
2. Query pending tickets across all users via `collectionGroup('tickets')` and gather `fixtureId ?? eventId` from each ticket's `tips[]` array. Missing IDs trigger a metadata lookup (`findFixtureIdByMeta`) using `eventName` and `startTime`, and the resolved `fixtureId` is cached back to the tip.
3. Fetch scores via `ResultProvider`, which now returns the `winner` and treats `FT/AET/PEN` as completed.
4. Evaluate each ticket's tips through the pluggable Market Evaluator registry (mapping `marketKey`, `outcome`, `odds`) and, once none remain `pending`, execute a Firestore **transaction** that:
   - computes payout via `calcTicketPayout`,
   - updates ticket `status`, `payout` and `processedAt`.
   The ticket owner is resolved from the `userId` field (fallback: path segment) and any positive payout is credited to `wallets/{uid}` via `CoinService.credit(uid, amount, ticketId)`, which writes an idempotent `ledger/{ticketId}` entry.
   Idempotency is enforced by checking `processedAt` and the wallet ledger.
5. Future step: create `notifications/{uid}` document and send FCM push.

This document covers the TypeScript skeleton with atomic payout handling.

**Runtime**: Node.js 20 on 2nd gen Cloud Functions.
Uses the firebase-functions v2 `onMessagePublished` trigger, avoiding the legacy `GCLOUD_PROJECT` requirement.
`API_FOOTBALL_KEY` is injected from Secret Manager via `defineSecret` and exposed as `process.env.API_FOOTBALL_KEY`.
`retry: true` is enabled and structured logs are emitted via `firebase-functions/logger`.
