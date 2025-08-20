# 🎯 Funkció

Ebben a vászonban a **kliens oldali írási útvonalak teljes átállítását** rögzítjük a *root* `wallets/*` és `tickets/*` útvonalakról a **user‑centrikus** `users/{uid}/wallet` és `users/{uid}/tickets/{ticketId}` ágakra, valamint ehhez az **eng. szabályok finomhangolását**. A cél, hogy a kliens **ne** írjon pénzügyi adatot (wallet/ledger), csak **jegyet** (`tickets`) hozzon létre a saját ágán, a pénzmozgás pedig **Cloud Functions‑ben** történjen.

---

# 🧠 Lépések (összefoglaló)

1. **Rules finomhangolás**

   * A `tickets/*` gyökérkollekció **create letiltása** (read marad backward kompatibilitás miatt).
   * Új szabály: `users/{userId}/tickets/{ticketId}` → **owner create/read**; update/delete tiltott.
   * A `users/{uid}/wallet` és `users/{uid}/ledger/*` továbbra is **read‑only kliensnek**.

2. **Kliens útvonalak átállítása**

   * `MyTickets` stream: `tickets/*` → `users/{uid}/tickets/*` (owner path, nincs több `where userId == uid`).
   * `StatsService`: a globális statokhoz `collectionGroup('tickets')`, per‑user számolásnál `users/{uid}/tickets/*`.

3. **Pénzügy kliensen: write kivezetés**

   * `CoinService.debitCoin/creditCoin`: **lokális wallet tranzakció törölve**, helyette csak `coin_trx` CF hívás.
   * `CoinService.debitAndCreateTicket`: **nincs több lokális wallet dedikció**; sorrend: **jegy létrehozás `users/{uid}/tickets` alatt → `coin_trx` debit (reason: 'bet', transactionId = ticketId)**; hiba esetén a jegy **kompenzációs törlése**.
   * `hasClaimedToday`: a `wallets/{uid}/coin_logs` query helyett **`users/{uid}/ledger`** (`source == 'daily_bonus'`, időintervallum `createdAt` szerint).

4. **QA**

   * Jegy létrehozása után CF debit lefut, wallet az új SoT‑on nő/csökken, ledgerben új sor (idempotens `refId` = ticketId / daily dátum).
   * Rules: kliens wallet/ledger write → **permission denied**; `users/{uid}/tickets` create → **OK**.

---

# ⚙️ Mellékletek

A konkrét diffek a **`fill_canvas_client_write_paths_refactor.yaml`** vászonban vannak. A YAML hivatkozik erre a tervre, mint kiegészítő információra.

---

# 📎 Kapcsolódások

* Előzmények: „Rules v1 + duplairás CF” és „Rules v2 + duplairás lekapcsolás” vásznak (SoT = `users/{uid}/wallet` + `users/{uid}/ledger`).
* Dokumentumok: „Tippmix App – User‑centrikus Firestore Architektúra (összefoglaló)”, „Bonus Engine – Firestore Tárolási Terv (v1)”.
