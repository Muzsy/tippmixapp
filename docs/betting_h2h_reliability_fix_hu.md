version: "2025-08-17"
last_updated_by: codex-bot
depends_on: []

# Fogadási H2H megbízhatósági javítás

- A `getH2HForFixture` csak sikeres, nem null eredményt cache-el; üres választ vagy hibát nem tárol.
- A `getOddsForFixture` 429 státusz esetén 200 ms várakozás után egyszer újrapróbál, és a hibát továbbadja a hívónak.
- Debug módban `X-Client: tippmixapp-mobile` fejlécet adunk és logoljuk a kimenő `/odds` URL-eket.
