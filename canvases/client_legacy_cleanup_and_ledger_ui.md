# 🎯 Cél

A kliensből minden **legacy hivatkozás** (root `wallets/*`, `coin_logs/*`, gyökér `tickets/*`) finom takarítása, és a **bónusz/ledger megjelenítések** végső összehangolása az új user‑centrikus SoT‑hoz:

* Pénzügyi SoT: `users/{uid}/wallet` + `users/{uid}/ledger/{entryId}` (kliens **csak olvas**).
* Jegyek: `users/{uid}/tickets/{ticketId}` (kliens **csak create/read** a saját ágán).
* Daily bonus állapot: `users/{uid}/ledger` ( `source == 'daily_bonus'`, időablak `createdAt`).

---

# 🧩 Módosítási csomag

1. **Rules finomhangolás**

   * Gyökér `tickets/*` **create tiltása**; új blokk: `users/{userId}/tickets/{ticketId}` owner create + read.

2. **Kliens – legacy takarítás**

   * `CoinService`:

     * `debitCoin`/`creditCoin` kliens oldali wallet‑módosítás **eltávolítva** → csak `coin_trx` CF hívás.
     * `hasClaimedToday()` → `users/{uid}/ledger` ( `source: 'daily_bonus'`, `createdAt` intervallum ).
     * `debitAndCreateTicket()` → jegy a `users/{uid}/tickets` alá, majd CF debit; hibánál **kompenzációs törlés**.
   * `MyTickets` stream → `users/{uid}/tickets` path.
   * `StatsService` → coin **wallet docból**, jegyek per‑user ágról; leaderboard aggregáció `collectionGroup('tickets')`.

3. **Bonus/ledger UI összhang**

   * A Daily Bonus csempe a fenti `hasClaimedToday()`‑t használja (ledger alapú), a coin header pedig a `StatsService` által olvasott `wallet.coins`‑t mutatja.

---

# 🧪 QA fókusz

* Kliens **nem** tud `wallet/ledger` alá írni (Rules hiba várható).
* `MyTickets` helyesen listáz a user ágáról.
* Bonus claim után: `users/{uid}/ledger/{entryId}` új sor, `users/{uid}/wallet.coins` frissül (szerveren). A UI balansz **nem** inkoherens (nincs kliens oldali wallet‑írás).

---

# 🔗 Hivatkozások

* „Tippmix App – User‑centrikus Firestore Architektúra (összefoglaló)” és „Bonus Engine – Firestore Tárolási Terv (v1)” – SoT és bonus flow elvek.
* Előzmények: Rules v1 → Rules v2 → jelen csomag (kliens teljes tisztítás + UI összhang).
