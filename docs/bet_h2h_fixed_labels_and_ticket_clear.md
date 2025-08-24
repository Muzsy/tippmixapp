version: "2025-10-21"
last_updated_by: codex-bot
depends_on: []

# Bet H2H fixed labels and ticket clear

- H2H buttons display fixed localized labels (`home_short`, `draw_short`, `away_short`).
- On successful ticket submit the `betSlipProvider` is cleared, a SnackBar shows `ticket_submit_success`, and navigation returns to the bets screen via `context.goNamed(AppRoute.bets.name)`.
