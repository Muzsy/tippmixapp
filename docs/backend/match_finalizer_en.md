version: "2025-08-12"
last_updated_by: codex-bot
depends_on: []

# 🧮 match_finalizer Cloud Function (EN)

Background worker processing `result-check` Pub/Sub messages. Its responsibilities:

1. Decode job type (`kickoff-tracker`, `result-poller`, `final-sweep`).
2. Query **all** user tickets via `collectionGroup('tickets')` and gather `eventId`s from each ticket's `tips[]` array.
3. Fetch scores via `ResultProvider`, keeping track of the winning team name for completed events.
4. Evaluate each ticket's tips and, once none remain `pending`, execute a Firestore **transaction** that:
   - computes payout via `calcTicketPayout`,
   - updates ticket `status`, `payout` and `processedAt`,
   - credits the user's `balance` atomically.
   Idempotency is enforced by checking `processedAt`.
5. Future step: create `notifications/{uid}` document and send FCM push.

This document covers the TypeScript skeleton with atomic payout handling.

**Runtime**: Node.js 20 on 2nd gen Cloud Functions.
