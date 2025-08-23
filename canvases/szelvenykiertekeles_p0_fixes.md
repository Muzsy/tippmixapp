# Szelvénykiértékelés – P0 javítások (konkrét diffek)

**Cél (P0/MVP):** a szelvények tényleges létrehozása és a kiértékelő pipeline végigfutása felhasználói jegyekre. Jelenleg a `TicketService.createTicket` csak stub, így nem keletkeznek `users/{uid}/tickets` dokumentumok → a `match_finalizer` nem talál „pending” jegyeket.

## Mit javítunk most (P0)

1. **Mobil (Flutter)** – `TicketService.createTicket` bevezetése Firestore‑írással a meglévő **security rules** szerint:

   * Írás útvonala: `users/{uid}/tickets/{autoId}`
   * Kötelező mezők: `id, userId, tips, stake, totalOdd, potentialWin, createdAt, updatedAt, status`
   * Kezdő státusz: `pending`
   * `totalOdd` = tippek szorzata; `potentialWin` = `stake * totalOdd`
   * Szerveridő: `FieldValue.serverTimestamp()`

2. **Backend (Cloud Functions)** – felesleges import eltávolítása a `match_finalizer` fájlból (CI/tsc warning).

3. **Dokumentációs apróság** – `OddsEvent` modell kommentek frissítése „API‑Football” terminológiára (félrevezető „OddsAPI” maradékok cseréje).

## Várható eredmény

* Jegy létrehozásakor azonnal megjelenik egy `users/{uid}/tickets/{id}` dokumentum `status: "pending"` állapottal.
* A `match_finalizer` **collectionGroup('tickets')** alapján találja és oldalanként dolgozza fel a jegyeket; lezárt események után kiszámolja a kimeneteleket és **jóváírja a coinokat** (lásd: `CoinService`).
* A CI **build + analyze + tests** továbbra is zöld (Node 20, Firebase Rules teszt, Flutter analyze/test).

## Ellenőrzési lista

* [ ] Bejelentkezett felhasználóval létrehozott jegy megjelenik a Firestore‑ban a megfelelő mezőkkel.
* [ ] A jegy bekerül a `match_finalizer` batch‑be és a logokban látszik: `match_finalizer.pending_tickets_batch`.
* [ ] Nyertes/vesztes/void tippek helyesen számítódnak (`H2H` értékelő).
* [ ] Pénztárca jóváírás hibamentes (`wallet` + `ledger` írás CF tranzakcióban).

## Kapcsolódó Codex YAML

`codex/goals/szelvenykiertekeles_p0_fixes.yaml` – pontos diffekkel. (Lásd ezt a vásznat kiegészítő magyarázatként.)
