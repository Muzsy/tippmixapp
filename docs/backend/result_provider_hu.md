# 🏁 ResultProvider Service (HU)

Az OddsAPI /scores végpontját használó adapter. Prod módban élő HTTP-hívásokat végez, míg fejlesztéskor (`USE_MOCK_SCORES=true`) a `functions/mock_scores/` JSON mintáit olvassa.

## Funkciók
- Eseményazonosítókat 40-es csomagokra osztja.
- `MODE=dev` esetén mock üzemmódra vált.
- Hibát dob, ha hiányzik az `ODDS_API_KEY` vagy a válasz nem 200-as.

## Tesztelés
- Unit teszt fedi a mock módot az `oddsApiSample.json` segítségével.
