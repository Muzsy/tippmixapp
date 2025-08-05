version: "2025-08-07"
last_updated_by: codex-bot
depends_on: []

# 🧮 match_finalizer Cloud Function (EN)

Background worker processing `result-check` Pub/Sub messages. Its responsibilities:

1. Decode job type (`kickoff-tracker`, `result-poller`, `final-sweep`).
2. Query `tickets` collection for pending entries and collect `eventId`s.
3. Fetch scores via `ResultProvider` and decide win/loss for completed events.
4. Update ticket `status` and call `CoinService.credit()` for winners.
5. Future step: create `notifications/{uid}` document and send FCM push.

This document covers the TypeScript skeleton; coin transfer logic will be refined in `coin-credit-task`.
