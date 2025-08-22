version: "2025-10-01"
last_updated_by: codex-bot
depends_on: []

# 🧮 match_finalizer Cloud Function (HU)

Háttérfolyamat, amely a `result-check` Pub/Sub üzeneteket dolgozza fel. Feladatai:

1. A payloadból kiolvassa a feladat típusát (`kickoff-tracker`, `result-poller`, `final-sweep`).
2. A függvény a függő szelvényeket `collectionGroup('tickets')` lekérdezéssel gyűjti az összes felhasználó alatti `/tickets/{uid}/tickets/{ticketId}` struktúrából, és a `fixtureId ?? eventId` értékeket a `tips[]` tömbből olvassa. Ha hiányzik vagy nem egyértelmű az ID, a `findFixtureIdByMeta` metakereső csapatnevek és kezdési idő alapján feloldja, majd visszaírja a `fixtureId`-t a tippre.
3. A `ResultProvider` visszaadja a `winner` mezőt, és az `FT/AET/PEN` státuszokat lezártnak tekinti.
4. A tippek kiértékelését a bővíthető Market Evaluator registry végzi (`marketKey`, `outcome`, `odds` mezők), és ha egy sem `pending`, egyetlen Firestore **tranzakcióban**:
   - kiszámolja a kifizetést a `calcTicketPayout` függvénnyel,
   - frissíti a ticket `status`, `payout`, `processedAt` mezőit.
   A ticket tulajdonosa a `userId` mezőből (fallback: útvonal) kerül meghatározásra, és a pozitív kifizetés a `CoinService.credit(uid, amount, ticketId)` hívással kerül jóváírásra a `wallets/{uid}` ág alatt, idempotens `ledger/{ticketId}` bejegyzéssel.
   Az idempotenciát a `processedAt` mező és a wallet ledger védi.
5. Következő lépésként `notifications/{uid}` dokumentumot hoz létre és FCM push-t küld.

Ez a dokumentum a TypeScript vázat írja le, immár atomikus kifizetéssel.
**Futtatókörnyezet**: Node.js 20, 2. generációs Cloud Functions.
A `firebase-functions` v2 `onMessagePublished` triggert használja, így nem szükséges a régi `GCLOUD_PROJECT` környezeti változó.
Az `API_FOOTBALL_KEY` titok a Secret Managerből `defineSecret` segítségével kerül be és `process.env.API_FOOTBALL_KEY` néven érhető el.
