# Match finalizer – fixtureId normalizálás + wallet‑kredit + mezőnév‑fix

## 🎯 Funkció

A `match_finalizer` feladata a függőben lévő szelvények (tickets) kiértékelése API‑Football eredmények alapján, a szelvény státusz (won/lost/void) beállítása és a nyeremény TippCoin jóváírása **wallet** alapon (idempotens ledgerrel). A jelenlegi állapotban több jegy *pending* marad, mert a tippekben lévő azonosító nem minden esetben API‑Football **fixtureId**, valamint a felhasználó azonosító mezője (`uid` vs `userId`) nem konzisztens.

## 🧠 Fejlesztési részletek

* **fixtureId normalizálás:** a tippekben elsődlegesen `fixtureId` (szám) legyen. A finalizer runtime‑ban támogatja a `fixtureId ?? eventId` mintát, és ha ez mégsem API‑Football azonosító, csapatnevek + kezdési idő alapján feloldja (`findFixtureIdByMeta`) és visszaírja a tippre cache‑ként.
* **wallet‑kredit:** a jóváírás a `CoinService.credit(uid, coins, ticketId)` híváson keresztül történik. A ledger kulcs a `ticketId`, így a könyvelés idempotens. A `users.balance/coins` közvetlen írása megszűnik.
* **mezőnév‑fix:** a user azonosítót a ticket `userId` mezőjéből olvassuk, fallback a path‑ból (`/tickets/{uid}/tickets/{ticketId}`), így a régi adatok is működnek.
* **build biztosítás:** Gen2 CF alatt a TS → JS fordítást a `gcp-build` script garantálja, hogy a frissített kód kerüljön futtatásra.
* **diagnosztika:** kiterjesztett logok: nyers üzenet, parse eredmény, talált ticketek száma, egyes tippek feloldási állapota, zárás eredménye.

## 🧪 Tesztállapot

* **Unit/integ. (backend):** a `findFixtureIdByMeta` segédfüggvényhez és a tip‑feldolgozási ághoz ellenőrző tesztek (mockolt API‑Football válaszokkal).
* **Manuális:**

  1. Pending jegy(ek) létrehozása ismert meccsre.
  2. Pub/Sub: `result-check` → `{ "job":"final-sweep" }`.
  3. Várható: ticket `status` frissül, `processedAt` kitöltődik, `tips[].fixtureId` pótlódik (ha hiányzott), `wallets/{uid}` nő, ledger‑bejegyzés `ledger/{ticketId}` létrejön.

## 🌍 Lokalizáció

* Nincs végfelhasználói szövegváltozás; kizárólag backend logok érintettek.

## 📎 Kapcsolódások

* **API‑Football** (fixtures, eredmények)
* **Firestore**: `tickets`, `wallets`, `wallets/{uid}/ledger`
* **Pub/Sub**: `result-check` topic
* **Kapcsolódó dokumentum**: `wallet.pdf`

---

**Megjegyzés:** a pontos, a jelenlegi kódra illeszkedő diffek a hozzá tartozó Codex YAML‑ban találhatók.
