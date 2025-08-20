# 🎯 Funkció

A „Rules v2 + duplairás lekapcsolás” célja, hogy a pénzügyi **Single Source of Truth (SoT)** véglegesen a `users/{uid}/wallet` + `users/{uid}/ledger/{entryId}` ág legyen, és **minden** legacy írás (root `wallets/*`, `coin_logs/*`, `users/{uid}.coins`) megszűnjön. A kliens továbbra is csak **olvas** a wallet/ledger alól; **minden** könyvelés Cloud Functions‑ben történik tranzakcióban.

---

# 🧠 Fejlesztési részletek

## 1) Rules v2 – végleges jogosultsági modell

* **Új SoT szabályok** felvétele (ha még nem léteznek):

  * `match /users/{uid}/wallet { allow read: isOwner(uid); allow write: if false; }`
  * `match /users/{uid}/ledger/{entryId} { allow read: isOwner(uid); allow write: if false; }`
* **Legacy write tiltása**:

  * `match /wallets/{userId}` és alatta `ledger` → `allow write: if false;`
  * `match /coin_logs/{logId}` → `allow create, update, delete: if false;` (read maradhat saját adatra)

> Megjegyzés: Admin SDK (CF) **megkerüli** a Rules‑t, ezért a tiltás **nem elég** – a szerver kódot is módosítjuk (lásd lejjebb).

## 2) CF – duplairás teljes kivezetése

**Érintett fájlok (a `tippmixapp.zip` alapján):**

* `cloud_functions/src/services/CoinService.ts` – jelenleg `wallets/{uid}` + `wallets/{uid}/ledger/{ticketId}`.
* `cloud_functions/coin_trx.logic.ts` – jelenleg `users/{uid}.coins` + `coin_logs`.
* `cloud_functions/log_coin.ts` – jelenleg `coin_logs`.
* (Információ) `cloud_functions/src/match_finalizer.ts` – már `CoinService().credit(...)`‑et hív.

**Véglegesítés:**

* `CoinService.transact(...)` csak az **új SoT‑ra** ír: `users/{uid}/wallet` + `users/{uid}/ledger/{ticketId}`.
* `coin_trx` callable: kizárólag `users/{uid}/wallet` + `users/{uid}/ledger/{transactionId}`, a `users/{uid}.coins` és a `coin_logs` írás megszűnik.
* `log_coin` callable: naplózás a `users/{uid}/ledger/{transactionId}` alá ( `source: 'log_coin'` ).
* `onUserCreate`: a kezdeti egyenleg **wallet doc‑ba** kerül; a `users/{uid}` **nem** tartalmaz `coins` mezőt.

## 3) Árnyékfutás → vágópont

* V2‑ben a duplairás **ki van kapcsolva** (szerveroldal). A Rules is tiltja a legacy write‑ot, de a tényleges garancia a kódmódosítás.
* Monitoring: ledger duplikáció (azonos `entryId`), negatív balance, CF kivételek.

## 4) Kliens illeszkedés (kockázat)

* A kliens **ne** írjon wallet‑et; a jelenlegi `lib/services/coin_service.dart` tranzakciós wallet‑írása későbbi lépésben kerül kivezetésre. V2 scope‑ja: **szerveroldali** duplairás megszüntetése + Rules v2.
* A **kliens olvasás** már V1‑ben az új SoT‑ra állt át ( `users/{uid}/wallet.coins` ), így a megjelenítés nem a legacy mezőkre támaszkodik.

---

# 🧪 Tesztállapot

1. **Unit/e2e CF teszt** (`cloud_functions/test`):

   * `finalizer_atomic` nyereménykönyvelés → ledger bejegyzés az `users/{uid}/ledger/{ticketId}` alatt, wallet increment csak az új SoT‑ban.
   * `coin_trx` idempotencia: ugyanazzal a `transactionId`‑val másodjára **nincs** új ledger sor.
2. **Manual QA**: készíts egy pending ticketet → finalizer lefut → wallet.coins nő, ledger új sor. `wallets/*` és `coin_logs/*` **nem** változik.

---

# 🌍 Lokalizáció

Nem érintett. A ledger/type/source mezőket a kliens lokalizálja.

---

# 📎 Kapcsolódások

* Elvek: „Tippmix App – User‑centrikus Firestore Architektúra (összefoglaló)” + „Bonus Engine – Firestore Tárolási Terv (v1)” (SoT = `users/{uid}/wallet` + `users/{uid}/ledger`).
* Következő lépés (külön vászon): **Kliens írási útvonalak** teljes kivezetése (root `wallets`, `tickets`) a user‑centrikus ágra, és ehhez illesztett Rules finomhangolás.
