# 🏁 ApiFootballResultProvider Service (HU)

Az API-Football fixtures végpontját használó adapter. Prod módban élő HTTP-hívásokat végez, míg fejlesztéskor (`USE_MOCK_SCORES=true`) a `cloud_functions/mock_apifootball/` JSON mintáit olvassa.

## Funkciók
- Eseményazonosítókat 40-es csomagokra osztja.
- `MODE=dev` esetén mock üzemmódra vált.
- Hibát dob, ha hiányzik az `API_FOOTBALL_KEY` vagy a válasz nem 200-as.
- `FT/AET/PEN` státuszokat lezártnak tekinti és visszaadja a `winner` mezőt (hazai/idegen/döntetlen).

## Tesztelés
- Unit teszt fedi a mock módot a `fixtures_sample.json` segítségével.
