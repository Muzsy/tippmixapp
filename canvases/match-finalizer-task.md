# Cloud Function – **match-finalizer-task**

## Kontextus

A `result-check` Pub/Sub topic üzeneteit mostantól egy háttér‑funkció dolgozza fel. Ez a *match\_finalizer*:

1. **Payload** alapján eldönti, melyik szubrutin fusson (kickoff‑tracker / result‑poller / final‑sweep).
2. Lekéri a releváns `eventId`‑ket Firestore‑ból (`tickets` collection, `status = pending`).
3. Meghívja a **ResultProvider**‑t → összeveti az OddsAPI „completed” meccseket a szelvényekkel.
4. **Transaction**: frissíti a ticket `status`‑át (won/lost) + hívja `CoinService.credit()` a nyereményhez.
5. Létrehoz egy `notifications/{uid}` doc‑ot, majd FCM push.

Ez a task csak a **váz (skeleton)** megírására koncentrál – a coin‑tranzakció részleteit a következő *coin-credit-task* finomítja.

## Feladatok

* [ ] `functions/src/match_finalizer.ts` – Pub/Sub trigger + dispatcher + Firestore query + TODO blokkok.
* [ ] `functions/src/services/CoinService.ts` – minimál “credit” stub (`// TODO implement in coin-credit-task`).
* [ ] `functions/test/match_finalizer.spec.ts` – unit: mock ResultProvider & Firestore Admin SDK. Assert, hogy *pending* ticket „won”-ra vált, és CoinService.credit hívódik.
* [ ] Update `package.json` jest config, add `@firebase/testing` / `ts-jest` devDeps.

## Acceptance Criteria

* Jest‑teszt zöld lokálisan (`npm test --prefix functions`).
* Cloud Function export neve: **match\_finalizer** (GCP deploy kompatibilis).
* Logger figyelmeztet, ha `process.env.ODDS_API_KEY` hiányzik vagy `ResultProvider` dob hibát.

## Függőségek

* **result-provider-task** (adapter már kész)
* **env-setup‑task** (env betöltéshez)
* **pubsub‑topics + scheduler‑jobs** (nem blokkoló kód‑szinten).
