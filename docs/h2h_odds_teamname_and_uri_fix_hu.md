version: "2025-08-17"
last_updated_by: codex-bot
depends_on: []

# H2H odds csapatnév és URI javítás

- A `h2hFromApi` opcionálisan megkapja a `homeName`/`awayName` paramétereket, így felismeri a csapatnév alapú értékeket.
- Bővült az alias lista `home/away` névvel, kétkimenetes piacokat is feldolgoz.
- Az `EventBetCard` továbbítja az `event.homeTeam` és `event.awayTeam` neveket a service felé.
- Az odds lekérés `Uri`-val építi a query-t, kizárva az összefolyást.
- 429 válasz esetén 200 ms várakozás után egyszer újrapróbál.
- A H2H cache csak sikeres eredményt tárol, null esetén törli a bejegyzést.
