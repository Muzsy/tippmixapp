version: "2025-08-31"
last_updated_by: codex-bot
depends_on: []

# /odds kérés megerősítése

- `bookmaker` paraméter alapértelmezett ID-val, kisebb válaszméret.
- Odds HTTP státuszkód logolása assert módban a diagnosztikához.
- Eseménykártya regex-szel nyeri ki a numerikus fixture azonosítót.
- Szezon paraméter hiányában az esemény évét használjuk.
