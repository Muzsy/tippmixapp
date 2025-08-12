version: "2025-08-12"
last_updated_by: codex-bot
depends_on: []

# 🧮 match_finalizer Cloud Function (HU)

Háttérfolyamat, amely a `result-check` Pub/Sub üzeneteket dolgozza fel. Feladatai:

1. A payloadból kiolvassa a feladat típusát (`kickoff-tracker`, `result-poller`, `final-sweep`).
2. A **felhasználók összes szelvényét** a `collectionGroup('tickets')` segítségével kérdezi le, és az `eventId`-ket a `tips[]` tömbből gyűjti.
3. A `ResultProvider` a győztes csapat nevét is visszaadja, így pontosan eldönthető az eredmény.
4. A tippek kiértékelése után, ha egy sem `pending`, egyetlen Firestore **tranzakcióban**:
   - kiszámolja a kifizetést a `calcTicketPayout` függvénnyel,
   - frissíti a ticket `status`, `payout`, `processedAt` mezőit,
   - jóváírja a felhasználó `balance` mezőjét.
   Az idempotenciát a `processedAt` mező védi.
5. Következő lépésként `notifications/{uid}` dokumentumot hoz létre és FCM push-t küld.

Ez a dokumentum a TypeScript vázat írja le, immár atomikus kifizetéssel.
**Futtatókörnyezet**: Node.js 20, 2. generációs Cloud Functions.
