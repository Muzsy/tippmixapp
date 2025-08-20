# 🎯 Funkció

Ebben a vászonban a **Rules v1**, a **Cloud Functions duplairás (legacy → user‑centrikus SoT)**, valamint a **kliens olvasás átállítása** kerül végrehajtási tervként összefoglalásra. A cél, hogy a pénzügyi SoT a `users/{uid}/wallet` + `users/{uid}/ledger/{entryId}` ág legyen, miközben a régi írások (pl. `wallets/{uid}`, `coin_logs`, `users/{uid}.coins`) átmenetileg **árnyékban szinkronban maradnak**.

---

# 🧠 Fejlesztési részletek

## 1) Firestore Rules v1

* Új, kifejezett szabályok a **user‑centrikus SoT**-hoz:

  * `match /users/{uid}/wallet { read: isOwner(uid); write: false; }`
  * `match /users/{uid}/ledger/{entryId} { read: isOwner(uid); write: false; }`
* A kliens **nem** írhat `wallet/ledger` alá; minden pénzmozgás CF‑ben történik (Admin SDK bypass).
* A meglévő (legacy) szabályok változatlanul maradnak egyelőre.

## 2) CF duplairás (átmenet)

### 2.1 `coin_trx.logic.ts` (callable és onUserCreate)

* **onUserCreate**: a `users/{uid}` kezdeti doc mellett létrejön a **`users/{uid}/wallet`** is (50 coin seed), hogy az app azonnal olvashassa az új SoT‑ot.
* **coin\_trx tranzakció**: a régi update (`users/{uid}.coins` + `coin_logs`) mellett **tükrözött írás** az új SoT‑ra: `users/{uid}/wallet` (increment) és `users/{uid}/ledger/{trxId}` (audit sor, idempotens `trxId`).

### 2.2 `match_finalizer.ts`

* A nyeremény jóváírás (`CoinService().credit`) után **explicit mirror write** az új SoT‑ra (`users/{uid}/wallet`, `users/{uid}/ledger/{ticketId}`), amíg a `CoinService` refaktor (teljes kettős írás) végleg be nem fejeződik.

### 2.3 `CoinService.ts` (előrefutó lépés)

* Előkészítő módosítás: **új refek** az új SoT‑ra (`users/{uid}/wallet`, `users/{uid}/ledger/{ticketId}`) — ezzel a későbbi teljes átállás (egy tranzakcióban mindkettő írása) egyszerűbb. A mostani patch **nem bontja szét** az eddigi tranzakciós logikát.

## 3) Kliens olvasás átállítása

* **`StatsService`** váltása:

  * coin balance: először `users/{uid}/wallet.coins` olvasása, fallback a régi `users/{uid}.coins` mezőre (átmenethez).
  * szelvények számlálása: root `tickets` helyett `collectionGroup('tickets')` (userenkénti filterrel), hogy passzoljon a user‑centrikus struktúrához.
* A UI‑ban nem változtatunk nagyot: a meglévő stat header a `StatsService` által szolgáltatott értéket fogja megjeleníteni.

## 4) Árnyékfutás & vágópont

* Pár napig megy a **duplairás** (legacy ↔ új SoT). Monitoring:

  * negatív balance, kettős ledger, CF hibák.
* Ha stabil, következő körben: **Rules v2** (régi útvonalak write tiltása) + `CoinService`/`coin_trx` tisztítás (csak az új SoT írása).

---

# 🧪 Tesztállapot

* **Unit/integ tesztek CF‑re**: `finalizer_atomic.test.ts`, e2e ticket flow — ellenőrizd, hogy ledger sor és wallet increment megjelenik **mindkét** helyen (legacy+új SoT).
* **App futtatás**: felhasználói statoknál a coin érték az új `users/{uid}/wallet.coins` alapján is helyes.
* **Rules verifikáció**: kliens oldali közvetlen `wallet/ledger` ír kísérlet **permission denied** legyen.

---

# 🌍 Lokalizáció

* Nincs változás a kulcsokban; ledger/type/source kódokból a UI fordít. A módosítások csak path‑szintűek.

---

# 📎 Kapcsolódások

* Forrás: „Tippmix App – User‑centrikus Firestore Architektúra (összefoglaló)” és „Bonus Engine – Firestore Tárolási Terv (v1)” (SoT = wallet+ledger, kliens write tiltás).
* Következő lépés (külön vászon/YAML): **Rules v2 + duplairás lekapcsolása**, `CoinService` véglegesítése (egyetlen SoT írás).
