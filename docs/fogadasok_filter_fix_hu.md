version: "2025-08-17"
last_updated_by: codex-bot
depends_on: []

# Fogadások szűrő javítás

- A szűrősáv üres lista esetén is látható.
- Hálózati lekérés csak dátumváltáskor indul; ország és liga szűrés kliensoldalon történik.
- A szűrősáv legördülői Wrap elrendezést és tágabb menüket kaptak az overflow elkerülésére.
- A cache kulcs csak sportot és dátumot tartalmaz, elkerülve a duplikációt.
- A fixtures kérésből kikerült az ország és liga paraméter, a szűrés helyben zajlik.
