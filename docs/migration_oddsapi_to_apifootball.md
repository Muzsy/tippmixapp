# Migration: OddsAPI to API-Football (EN)

This note summarizes the removal of the legacy OddsAPI integration and the switch to API-Football.

## Changes
- OddsAPI secrets and configs removed from CI and local env files.
- Cloud Functions use `ApiFootballResultProvider` with `API_FOOTBALL_KEY`.
- GitHub workflows reference `API_FOOTBALL_KEY` secret.
- Frontend `ApiFootballService.getOdds` calls the `/odds` endpoint with `fixture`, optional `season` and `bet=1X2` parameters, mapping "Match Winner" bets to the internal `h2h` market and storing league, country and season on `OddsEvent`.
- Frontend `ApiFootballService` enriches fixtures with a minimal "match winner" (`h2h`) market by calling `/odds?fixture={id}&season={yyyy}&bet=1X2` for the first available bookmaker and falls back to an empty market list if odds are missing.

## Local setup
1. Add `API_FOOTBALL_KEY` to your `.env`.
2. Ensure the same key is configured as a GitHub secret.
