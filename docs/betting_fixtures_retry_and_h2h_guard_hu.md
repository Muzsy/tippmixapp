version: "2025-08-30"
last_updated_by: codex-bot
depends_on: []

# Fogadási fixtures retry és H2H guard

- Bevezetve egyetlen retry 200 ms késleltetéssel a `GET /fixtures?date=` hívásra.
- Hozzáadva unit tesztek a retry logikára és a H2H guard-ra (fixtureId<=0 esetén nincs hálózat).
