# Szelvénykiértékelés – match\_finalizer Firestore útvonal + tipp-kiértékelés javítás

## Kontextus

* **Tünet:** A Logs Explorer szerint a `match_finalizer` lefut ("batch commit done"), de a Firestore‑ban a szelvények **Függőben (pending)** státuszban maradnak, az appban is.
* **Valós ok (a `tippmixapp.zip` alapján):**

  1. A `cloud_functions/src/match_finalizer.ts` a **gyökér `tickets` kollekciót** kérdezi (`db.collection('tickets')`), miközben a tényleges szelvénydokumentumok **al‑kollekcióban** vannak: `/tickets/{uid}/tickets/{ticketId}`. Így a függvény **nem** a valódi szelvényeket frissíti.
  2. A függvény az `eventId`‑t a szelvény dokumentum tetején várja, valójában ez **a `tips[]` tömb elemein** belül található. Emiatt az eredmény‑lekérdezéshez is hibás az `eventId` gyűjtése.
  3. A kiértékelés jelenleg csak azt nézi, hogy a meccsen **a hazai nyert‑e** (home>away), **nem** azt, hogy a felhasználó **melyik csapatra tippelt**. Így akkor is „won” lehet, ha a user az idegenre tippelt, de a hazai nyert.

## Cél

A `match_finalizer` úgy keresse és frissítse a szelvényeket, hogy:

* a **valós dokumentumokra** mutasson (collection **group** query: `collectionGroup('tickets')`),
* az **összes tipp** (`tips[]`) `eventId`‑jából kérjen eredményt,
* a **győztes csapat** alapján értékelje a tippeket (OddsAPI → `home_team`/`away_team` + `scores`), és státuszokat állítson: `won` / `lost` / marad `pending`.

## Feladatok

* [ ] `match_finalizer.ts` – query csere: `collection('tickets')` → `collectionGroup('tickets')` + az `eventId`‑k összegyűjtése a `tips[]` mezőből.
* [ ] `match_finalizer.ts` – kiértékelési logika: szelvény `won`, ha **minden tipp** nyert; `lost`, ha **bármelyik** tipp biztosan bukott; egyébként `pending`.
* [ ] `ResultProvider.ts` – a `ScoreResult` bővítése az OddsAPI mezőkkel: `home_team`, `away_team` (ezeket az API amúgy is visszaadja), hogy a nyertest össze lehessen vetni a tipp `outcome` mezőjével (ami csapatnév).
* [ ] Batch frissítés **közvetlenül a találat `doc.ref`‑jére**, ne építsen új referenciát téves úttal.
* [ ] `npm run build` a `cloud_functions` alatt; futtatható marad a CI‑ben is.

## Done / Acceptance

* [ ] A `cloud_functions` fordul (TS build zöld).
* [ ] A `result-check` futtatása után a Firestore‑ban **a tényleges szelvénydokumentumok** (`/tickets/{uid}/tickets/{ticketId}`) státusza már **nem marad** pending: a befejezett meccsek alapján `won` vagy `lost`.
* [ ] A Logs Explorerben a "batch commit done" után **láthatóan** módosulnak a fenti dokumentumok.
* [ ] A pénztárca jóváírás (`CoinService.credit`) **csak akkor fut**, ha a szelvény új státusza `won` (nem változtatunk rajta, de a státusz most már helyesen kerül meghatározásra).

## Megjegyzések

* A Firestore adatbázis **europe-central2**; a Cloud Function régió ettől független (gen2), a kiértékelés javítása a fenti logikai és útvonal‑hibát orvosolja.
* A draw/döntetlen piacot most **nem** kezeljük, mert a meglévő `tips[]` és az OddsAPI mezők alapján az `h2h` (moneyline) jó/rossz kimenetel igazolható biztonsággal. Bővíthető később.
