version: "2025-10-21"
last_updated_by: codex-bot
depends_on: []

# Fogadási oldal – H2H fix címkék és szelvény ürítés

- A H2H gombok fix, lokalizált feliratot kapnak (`home_short`, `draw_short`, `away_short`).
- Sikeres szelvénybeküldés után kiürül a `betSlipProvider`, a SnackBar üzenete: „Szelvény beküldve”, majd név alapján (`context.goNamed(AppRoute.bets.name)`) visszanavigál a fogadások képernyőre.
