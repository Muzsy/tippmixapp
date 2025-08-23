version: "2025-10-03"
last_updated_by: codex-bot
depends_on: []

# Pub/Sub Topics

Terraform-managed Google Pub/Sub topics for the result evaluation pipeline.

## Topics

- `result-check`: primary topic for match finalizer results, 7-day retention.
- `match_finalizer-dlq`: dead-letter queue for failed finalizer messages, 7-day retention.

## Scheduler Jobs

The following Cloud Scheduler jobs publish to `result-check`:

- `kickoff-tracker-job`
- `result-poller-job`
- `final-sweep-job`
