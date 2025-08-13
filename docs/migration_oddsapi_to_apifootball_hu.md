# Migráció: OddsAPI → API-Football (HU)

Ez a jegyzet összefoglalja az OddsAPI integráció eltávolítását és az API-Footballra való átállást.

## Változások
- Az OddsAPI titkok és konfigurációk törölve a CI-ből és a helyi környezetből.
- A Cloud Functions az `ApiFootballResultProvider`-t használja `API_FOOTBALL_KEY` kulccsal.
- A GitHub workflow-k az `API_FOOTBALL_KEY` secretre hivatkoznak.
- A frontend `ApiFootballService.getOdds` most a `/odds` végpontot hívja, a "Match Winner" fogadást `h2h` piacra alakítva, és elmenti a liga és ország nevét az `OddsEvent`-be.
- A frontend `ApiFootballService` a meccsekhez minimális "match winner" (`h2h`) piacot csatol az `/odds?fixture={id}` hívás segítségével (Hazai/Döntetlen/Vendég), és ha nincs odds adat, az esemény üres bookmaker listával tér vissza.

## Helyi beállítás
1. Add hozzá az `API_FOOTBALL_KEY` kulcsot a `.env` fájlhoz.
2. Biztosítsd, hogy ugyanez a kulcs GitHub secretként is szerepeljen.
