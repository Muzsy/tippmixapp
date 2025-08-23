# 🏁 ApiFootballResultProvider Service (HU)

Az API-Football fixtures végpontját használó adapter. Prod módban élő HTTP-hívásokat végez, míg fejlesztéskor (`USE_MOCK_SCORES=true`) a `cloud_functions/mock_apifootball/` JSON mintáit olvassa.

## Funkciók
- Eseményazonosítókat 40-es csomagokra osztja.
- `MODE=dev` esetén mock üzemmódra vált.
- Hibát dob, ha hiányzik az `API_FOOTBALL_KEY` vagy a válasz nem 200-as.
- `FT/AET/PEN` státuszokat lezártnak tekinti és visszaadja a `winner` mezőt (hazai/idegen/döntetlen).
- `findFixtureIdByMeta(eventName,startTime)` segédfüggvény a `fixtureId` feloldására csapatnevek és kezdési idő alapján, ha csak metaadat áll rendelkezésre. A `GET /fixtures?date=YYYY-MM-DD&search=<team>` végpontot hívja meg mindkét csapatnévre, és kis/nagybetű-független név/idő egyezés alapján választja ki a megfelelő meccset.

## Tesztelés
- Unit teszt fedi a mock módot a `fixtures_sample.json` segítségével.
- Unit teszt ellenőrzi a `findFixtureIdByMeta` hibás input kezelését.
