# Migráció: OddsAPI → API-Football (HU)

Ez a jegyzet összefoglalja az OddsAPI integráció eltávolítását és az API-Footballra való átállást.

## Változások
- Az OddsAPI titkok és konfigurációk törölve a CI-ből és a helyi környezetből.
- A Cloud Functions az `ApiFootballResultProvider`-t használja `API_FOOTBALL_KEY` kulccsal.
- A GitHub workflow-k az `API_FOOTBALL_KEY` secretre hivatkoznak.
- A frontend `ApiFootballService.getOdds` a `/odds` végpontot hívja `fixture`, opcionális `season` és opcionális `bet=1X2` szűrő paraméterekkel, a "Match Winner" fogadást `h2h` piacra alakítva, és elmenti a liga, ország és szezon értékét az `OddsEvent`-be.
- A frontend `ApiFootballService` a meccsekhez minimális "match winner" (`h2h`) piacot csatol, először `/odds?fixture={id}&season={yyyy}&bet=1X2` hívással; ha ez üres, `bet` szűrő nélkül próbálkozik, és csak ezután tér vissza üres bookmaker listával.
- A H2H feldolgozás elfogadja a `Full Time Result`, `Match Result` és `Winner` elnevezéseket is a `Match Winner` és `1X2` mellett.
- A runtime `getH2HForFixture(fixture, season)` `<fixture>-<season>` kulcson cache-el, és ha a `bet=1X2` hívás üres, teljes oddsot kér le, majd a `response→bookmakers→bets→values` útvonalról építi fel a `Home/Draw/Away` kimeneteket.
- A preferált bookmaker kiválasztás mostantól ID-alapú: a frontend először a **8-as azonosítójú** (Bet365) bookmakert próbálja, és a tippekben a numerikus `bookmakerId` értéket tárolja.

## Helyi beállítás
1. Add hozzá az `API_FOOTBALL_KEY` kulcsot a `.env` fájlhoz.
2. Biztosítsd, hogy ugyanez a kulcs GitHub secretként is szerepeljen.
