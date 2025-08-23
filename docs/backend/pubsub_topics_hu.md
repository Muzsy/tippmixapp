version: "2025-10-03"
last_updated_by: codex-bot
depends_on: []

# Pub/Sub témák

Terraform által kezelt Google Pub/Sub témák a mérkőzés-kiértékelő folyamathoz.

## Témák

- `result-check`: fő téma, 7 napos retention.
- `match_finalizer-dlq`: Dead-Letter Queue a hibás finalizer üzeneteknek, 7 napos retention.

## Ütemezett feladatok

Az alábbi Cloud Scheduler jobok a `result-check` témára publikálnak:

- `kickoff-tracker-job`
- `result-poller-job`
- `final-sweep-job`
