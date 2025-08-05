# End‑to‑End teszt – **integration-e2e-task**

## Cél

Teljes happy‑path végigfuttatása **helyi Firebase emulatorban**:

1. „Fogadás” – kliens‑szimuláció: létrehoz egy *tickets* dokumentumot `status=pending`, `eventId=eventMock1`, `potentialProfit=200`, `uid=tester`.
2. A ResultProvider mock visszaadja a meccs végeredményét completed ➜ home nyert.
3. A Pub/Sub üzenet kézzel inject‑elve (`result-poller`).
4. **match\_finalizer** lefut ➜ ticket `status=won`, *wallets/tester.balance += 200*, ledger entry létrejön.

Teszt PASS, ha a fenti állapotok igazak ≤10 s‑en belül.

## Feladatok

* [ ] **e2e.test.ts** – Jest test, `@firebase/rules-unit-testing` + `firebase-functions-test` segítségével:

  * inicializál Firestore és Pub/Sub emulátorokat,
  * stubolja a ResultProvider‑t completed score‑ra,
  * létrehozza a pending ticketet,
  * hívja a `match_finalizer`-t a megfelelő base64 payloaddal,
  * vár *batch.commit()*‑re, majd assert‑ek.
* [ ] **npm script**: `npm run e2e` a *functions* mappában.
* [ ] **GitHub Actions workflow** `.github/workflows/e2e.yml` – felhúzza az emulátorokat, futtatja `npm ci`, `npm run e2e`.
* [ ] **jest-e2e.config.js** külön env‑setup (`MODE=dev`, `USE_MOCK_SCORES=true`).

## Acceptance Criteria

* E2E Jest‑teszt zöld lokálisan (`npm run e2e`).
* GH‑Actions workflow zöld (matrix: ubuntu‑latest, Node 18).
* Teszt ≤15 s alatt lefut (timeout 30 s).

## Függőségek

* **match-finalizer-task** – függvény export kész.
* **coin-credit-task** – tranzakciók működnek.
* **env-setup-task** – dev settings betöltéséhez.
