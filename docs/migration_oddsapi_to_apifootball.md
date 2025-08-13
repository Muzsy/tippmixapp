# Migration: OddsAPI to API-Football (EN)

This note summarizes the removal of the legacy OddsAPI integration and the switch to API-Football.

## Changes
- OddsAPI secrets and configs removed from CI and local env files.
- Cloud Functions use `ApiFootballResultProvider` with `API_FOOTBALL_KEY`.
- GitHub workflows reference `API_FOOTBALL_KEY` secret.

## Local setup
1. Add `API_FOOTBALL_KEY` to your `.env`.
2. Ensure the same key is configured as a GitHub secret.
