version: "2025-08-07"
last_updated_by: codex-bot
depends_on: []

# 🧮 match_finalizer Cloud Function (HU)

Háttérfolyamat, amely a `result-check` Pub/Sub üzeneteket dolgozza fel. Feladatai:

1. A payloadból kiolvassa a feladat típusát (`kickoff-tracker`, `result-poller`, `final-sweep`).
2. Lekérdezi a `tickets` kollekció függő tételeit és összegyűjti az `eventId`-ket.
3. A `ResultProvider` segítségével lekéri az eredményeket és eldönti a nyerés/verés státuszt.
4. Frissíti a szelvény `status` mezőjét és a nyerteseknek meghívja a `CoinService.credit(uid, potentialProfit, ticketId)` metódust.
5. Következő lépésként `notifications/{uid}` dokumentumot hoz létre és FCM push-t küld.

Ez a dokumentum a TypeScript vázat írja le; a coin tranzakció logika a `coin-credit-task` során finomodik.
