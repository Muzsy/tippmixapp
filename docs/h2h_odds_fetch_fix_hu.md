version: "2025-08-17"
last_updated_by: codex-bot
depends_on: []

# H2H odds lekérés javítás

- Az API-Football `bet` paraméterét egész `1`-re állítottuk a Match Winner piacért.
- Eltávolítottuk az eager H2H odds betöltést a meccslistáról; a kártya kéréskor tölti le 60 mp cache-el.
- Guard és memóriacache került a `getH2HForFixture` függvénybe.
- A kártya hálózati hívás előtt a meglévő oddsot használja.
- Az odds URL `Uri`-val épül, debug `X-Client` fejléccel.
- 200 ms backoff + egy retry történik HTTP 429 esetén.
- Csak nem null eredményt cache-elünk; null válasz nem kerül mentésre.

