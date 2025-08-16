# Migráció: OddsAPI → API-Football (HU)

Ez a jegyzet összefoglalja az OddsAPI integráció eltávolítását és az API-Footballra való átállást.

## Változások
- Az OddsAPI titkok és konfigurációk törölve a CI-ből és a helyi környezetből.
- A Cloud Functions az `ApiFootballResultProvider`-t használja `API_FOOTBALL_KEY` kulccsal.
- A GitHub workflow-k az `API_FOOTBALL_KEY` secretre hivatkoznak.
- A frontend `ApiFootballService.getOdds` a `/odds` végpontot hívja `fixture`, opcionális `season` és opcionális `bet=1X2` szűrő paraméterekkel, a "Match Winner" fogadást `h2h` piacra alakítva, és elmenti a liga, ország és szezon értékét az `OddsEvent`-be.
- A frontend `ApiFootballService` a meccsekhez minimális "match winner" (`h2h`) piacot csatol, először `/odds?fixture={id}&season={yyyy}&bet=1X2` hívással; ha ez üres, `bet` szűrő nélkül próbálkozik, és csak ezután tér vissza üres bookmaker listával.

## Helyi beállítás
1. Add hozzá az `API_FOOTBALL_KEY` kulcsot a `.env` fájlhoz.
2. Biztosítsd, hogy ugyanez a kulcs GitHub secretként is szerepeljen.
