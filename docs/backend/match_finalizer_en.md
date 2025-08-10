version: "2025-08-07"
last_updated_by: codex-bot
depends_on: []

# 🧮 match_finalizer Cloud Function (EN)

Background worker processing `result-check` Pub/Sub messages. Its responsibilities:

1. Decode job type (`kickoff-tracker`, `result-poller`, `final-sweep`).
2. Query **all** user tickets via `collectionGroup('tickets')` and gather `eventId`s from each ticket's `tips[]` array.
3. Fetch scores via `ResultProvider`, keeping track of the winning team name for completed events.
4. Evaluate each ticket: **won** if every tip matches the winner, **lost** if any tip fails, otherwise remain **pending**. Update `status` and call `CoinService.credit(uid, potentialProfit, ticketId)` for winners.
5. Future step: create `notifications/{uid}` document and send FCM push.

This document covers the TypeScript skeleton; coin transfer logic will be refined in `coin-credit-task`.

**Runtime**: Node.js 20 on 2nd gen Cloud Functions.
