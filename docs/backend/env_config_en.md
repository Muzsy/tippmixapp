# 🔧 Environment Config Loader (EN)

This document explains how Cloud Functions load non-secret configuration values.

## Files
- `env.settings.dev` – developer cron schedules, restricted sports list, low quota threshold.
- `env.settings.prod` – production cron schedules, all sports, high quota threshold.

## Loader
`functions/src/config.ts` reads `MODE` from the environment (`.env` is only used locally), then merges `env.settings.${MODE}`.
Secrets are injected from Google Secret Manager at runtime. The populated `process.env` is re-exported as `Config` for other modules.

## Cron variables

- `KICKOFF_TRACKER_CRON`
- `SCORE_POLL_CRON`
- `SCORE_SWEEP_CRON`

## Quota watcher

- `QUOTA_WARN_AT` – minimum remaining OddsAPI credits before alerting

## Global options and secrets
All Cloud Functions import `cloud_functions/global.ts` first. This module defines secrets such as `API_FOOTBALL_KEY` via `defineSecret` and sets `setGlobalOptions({ region: 'europe-central2', secrets: [API_FOOTBALL_KEY] })` to prevent region drift.
