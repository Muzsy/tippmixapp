version: "2025-08-04"
last_updated_by: codex-bot
depends_on: []

# Pub/Sub Topics

Terraform-managed Google Pub/Sub topics for the result evaluation pipeline.

## Topics

- `result-check`: primary topic for match finalizer results, 7-day retention.
- `result-check-dlq`: dead-letter queue for failed messages, 7-day retention.
