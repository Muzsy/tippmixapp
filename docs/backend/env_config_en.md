# 🔧 Environment Config Loader (EN)

This document explains how Cloud Functions load non-secret configuration values.

## Files
- `env.settings.dev` – developer cron schedules, restricted sports list, low quota threshold.
- `env.settings.prod` – production cron schedules, all sports, high quota threshold.

## Loader
`functions/src/config.ts` first loads secrets and `MODE` from `.env`, then merges `env.settings.${MODE}`.
It re-exports the populated `process.env` as `Config` for other modules.

## Cron variables

- `KICKOFF_TRACKER_CRON`
- `SCORE_POLL_CRON`
- `SCORE_SWEEP_CRON`

## Quota watcher

- `QUOTA_WARN_AT` – minimum remaining OddsAPI credits before alerting
