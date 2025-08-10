version: "2025-08-07"
last_updated_by: codex-bot
depends_on: []

# 🧮 match_finalizer Cloud Function (HU)

Háttérfolyamat, amely a `result-check` Pub/Sub üzeneteket dolgozza fel. Feladatai:

1. A payloadból kiolvassa a feladat típusát (`kickoff-tracker`, `result-poller`, `final-sweep`).
2. A **felhasználók összes szelvényét** a `collectionGroup('tickets')` segítségével kérdezi le, és az `eventId`-ket a `tips[]` tömbből gyűjti.
3. A `ResultProvider` a győztes csapat nevét is visszaadja, így pontosan eldönthető az eredmény.
4. Kiértékelés: akkor **nyert** a szelvény, ha minden tipp telitalálat; **vesztett**, ha bármelyik biztosan hibás; egyébként **függő** marad. Frissíti a `status` mezőt és a nyerteseknél meghívja a `CoinService.credit(uid, potentialProfit, ticketId)` metódust.
5. Következő lépésként `notifications/{uid}` dokumentumot hoz létre és FCM push-t küld.

Ez a dokumentum a TypeScript vázat írja le; a coin tranzakció logika a `coin-credit-task` során finomodik.
**Futtatókörnyezet**: Node.js 20, 2. generációs Cloud Functions.
