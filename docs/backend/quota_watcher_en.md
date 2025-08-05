# ⏱️ OddsAPI quota watcher (EN)

This document outlines the Terraform resources that monitor remaining OddsAPI credits and notify Slack when they drop too low.

## Terraform
- `infra/monitoring_alert.tf` defines the `remaining_credits` log metric and `credit_low_alert` policy.
- `infra/notification_channel.tf` configures the Slack notification channel.

## Environment variables
- `QUOTA_WARN_AT` – alert threshold for remaining credits.
- `SLACK_WEBHOOK_URL` – incoming WebHook for the Slack channel.
