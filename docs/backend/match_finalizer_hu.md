version: "2025-10-10"
last_updated_by: codex-bot
depends_on: []

# 🧮 match_finalizer Cloud Function (HU)

Háttérfolyamat, amely a `result-check` Pub/Sub üzeneteket dolgozza fel. Feladatai:

1. A payloadból kiolvassa a feladat típusát (`kickoff-tracker`, `result-poller`, `final-sweep`).
2. Lapozva dolgozza fel a függő szelvényeket (`FINALIZER_BATCH_SIZE`, `FINALIZER_MAX_BATCHES`) `orderBy('__name__') + startAfter(lastDoc)` segítségével. Ha marad még feldolgozatlan tétel, új üzenetet publikál a `RESULT_TOPIC` témára `attempt=0` attribútummal.
3. Minden batchnél a `tips[]` tömbből gyűjti a `fixtureId ?? eventId` értékeket. Hiányzó ID esetén a `findFixtureIdByMeta` metakereső csapatnév és kezdési idő alapján feloldja, majd visszaírja a `fixtureId`-t.
4. A `ResultProvider` visszaadja a `winner` mezőt, az `FT/AET/PEN` státuszokat lezártnak tekinti, és a `canceled` meccseket `void` tippként jelöli.
5. A tippek kiértékelését a bővíthető Market Evaluator registry végzi (`marketKey`, `outcome`, `odds` mezők); ha egy sem `pending`, egyetlen Firestore **tranzakcióban**:
   - kiszámolja a kifizetést a `calcTicketPayout` függvénnyel,
   - frissíti a ticket `status`, `payout`, `processedAt` mezőit.
   A ticket tulajdonosa a `userId` mezőből (fallback: útvonal) kerül meghatározásra, és a pozitív kifizetés a `CoinService.credit(uid, amount, ticketId)` hívással kerül jóváírásra, amely először ellenőrzi a `ledger/{ticketId}` dokumentum meglétét, és létezése esetén kihagyja a wallet írást (idempotens).
6. Hiba esetén a `attempt` attribútum növelésével újrasorolja az üzenetet; ha `attempt >= 2`, a `DLQ_TOPIC` témára küldi és `match_finalizer.sent_to_dlq` logot ír.
7. Következő lépésként `notifications/{uid}` dokumentumot hoz létre és FCM push-t küld.

Ez a dokumentum a TypeScript vázat írja le, immár atomikus kifizetéssel.
**Futtatókörnyezet**: Node.js 20, 2. generációs Cloud Functions.
A `firebase-functions` v2 `onMessagePublished` triggert használja, így nem szükséges a régi `GCLOUD_PROJECT` környezeti változó.
A belépési pont típusos `CloudEvent<MessagePublishedData>` eseményt kap, `hasMsg` és attribútumkulcsok naplózásával. Üres esemény esetén `match_finalizer.no_message` figyelmeztetést ír és visszatér.
Az `API_FOOTBALL_KEY` titok a Secret Managerből `defineSecret` segítségével kerül be és `process.env.API_FOOTBALL_KEY` néven érhető el.
`retry: true` engedélyezve van, és strukturált logolást használ a `firebase-functions/logger`.
