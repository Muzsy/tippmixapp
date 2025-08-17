# Cél

A H2H odds lekérések stabilizálása és láthatóvá tétele az API‑Football dashboardon. Két részből áll:

1. **URL összeállítás Uri-val** – ne legyen többé „season=2025bet=1” típusú összefolyás; mindig helyes query paraméterezés menjen ki.
2. **No‑cache‑on‑null** – a H2H csak sikeres eredményt cache-eljen, az üres/hibás hívás ne akadályozza az újrapróbát.
3. **429 kezelés + debug azonosító** – 200 ms backoff + 1× retry; debugban `X-Client: tippmixapp-mobile` fejléc és URL log.

# Érintett fájl

* `lib/services/api_football_service.dart`

# Elfogadási kritériumok

* A konzolban így látszik a kimenő kérés: `[odds] GET https://v3.football.api-sports.io/odds?fixture=…&season=…&bet=1`.
* A dashboard „Requests” listában megjelennek a `/v3/odds` sorok.
* A kártyákon az 1/X/2 oddsok megjelennek, ha az API ad piacot.
