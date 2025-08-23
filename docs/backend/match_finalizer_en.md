version: "2025-10-03"
last_updated_by: codex-bot
depends_on: []

# 🧮 match_finalizer Cloud Function (EN)

Background worker processing `result-check` Pub/Sub messages. Its responsibilities:

1. Decode job type (`kickoff-tracker`, `result-poller`, `final-sweep`).
2. Page through pending tickets in batches (`FINALIZER_BATCH_SIZE`, `FINALIZER_MAX_BATCHES`) using `orderBy('__name__') + startAfter(lastDoc)`. If more remain, the function self-enqueues another message on `RESULT_TOPIC` with `attempt=0`.
3. For each batch, gather `fixtureId ?? eventId` from `tips[]`. Missing IDs trigger a metadata lookup (`findFixtureIdByMeta`) using `eventName` and `startTime`, and the resolved `fixtureId` is cached back to the tip.
4. Fetch scores via `ResultProvider`, which returns the `winner` and treats `FT/AET/PEN` as completed.
5. Evaluate each ticket's tips through the pluggable Market Evaluator registry (mapping `marketKey`, `outcome`, `odds`) and, once none remain `pending`, execute a Firestore **transaction** that:
   - computes payout via `calcTicketPayout`,
   - updates ticket `status`, `payout` and `processedAt`.
   The ticket owner is resolved from the `userId` field (fallback: path segment) and any positive payout is credited to `wallets/{uid}` via `CoinService.credit(uid, amount, ticketId)`, which first checks `ledger/{ticketId}` and skips wallet writes if it exists (idempotent).
6. Errors trigger requeue with an incremented `attempt` attribute; on `attempt >= 2` the message is routed to `DLQ_TOPIC` and logged as `match_finalizer.sent_to_dlq`.
7. Future step: create `notifications/{uid}` document and send FCM push.

This document covers the TypeScript skeleton with atomic payout handling.

**Runtime**: Node.js 20 on 2nd gen Cloud Functions.
Uses the firebase-functions v2 `onMessagePublished` trigger, avoiding the legacy `GCLOUD_PROJECT` requirement.
`API_FOOTBALL_KEY` is injected from Secret Manager via `defineSecret` and exposed as `process.env.API_FOOTBALL_KEY`.
`retry: true` is enabled and structured logs are emitted via `firebase-functions/logger`.
