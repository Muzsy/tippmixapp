# 🎯 Funkció

A Firestore refaktor végpontjának lezárása a **Rules forrás
(\`firebase.rules\`) igazításával**, a **Cloud Functions duplairás megszüntetésével** és a **pénzügyi SoT véglegesítésével** (\`users/{uid}/wallet\` + \`users/{uid}/ledger/{entryId}\`). A változtatások a mostani `tippmixapp.zip` kódállományhoz vannak igazítva.

---

# 🧠 Fejlesztési részletek

## 1) Rules forrás egységesítése (firebase.rules)

* A projektben a deploy forrása jelenleg **`firebase.json` → `firestore.rules: firebase.rules`**. A helyes modell a `cloud_functions/firestore.rules` fájlban már elkészült, de **nem ez kerül deployra**.
* Feladat: **`firebase.rules`** frissítése a pénzügyi SoT-hoz illeszkedő szabályokra:

  * **`/wallets/{userId}`**: *write* **tilos** (legacy olvasás maradhat). A ledger aláírás *write* szintén **tilos**.
  * **`/users/{uid}/wallet`** és **`/users/{uid}/ledger/{entryId}`**: kliens **csak olvas**, *write* **tilos** (CF/Admin SDK írja).
  * **`/tickets/*` gyökérkollekció**: *create* **tilos** (írás csak `users/{uid}/tickets/{ticketId}` alá).

## 2) CF – duplairás kivezetése a match\_finalizer-ben

* A `cloud_functions/src/match_finalizer.ts` jelenleg a `CoinService().credit()` hívás **után** még egyszer **mirror write-ot** végez ugyanarra a SoT-ra (`users/{uid}/wallet` increment + `users/{uid}/ledger/{ticketId}` set), ami **kettős jóváíráshoz** vezethet.
* Feladat: a mirror blokk **eltávolítása**; a könyvelés kizárólag a `CoinService` idempotens tranzakcióján fusson.

## 3) CF – coin\_trx.logic SoT-véglegesítés

* A `cloud_functions/coin_trx.logic.ts` még a **legacy** utakat használja (`users/{uid}.coins` + `coin_logs`).
* Feladat: átállítás **teljesen** az új SoT-ra:

  * `onUserCreate`: ne a root `users/{uid}` doc `coins` mezőjét hozza létre, hanem **`users/{uid}/wallet`** doc-ot (`coins`, `updatedAt`).
  * `https.onCall('coin_trx')`: tranzakcióban **csak** `users/{uid}/wallet` + `users/{uid}/ledger/{transactionId}` módosuljon; a `coin_logs` és a root `users/{uid}.coins` **kivezetendő**.
  * Idempotencia: primer kulcs a ledgerben a **`transactionId`** legyen (determin. refId), vagy számolt checksum.

## 4) Build/deploy megjegyzés

* A Functions **futó** kódja a `cloud_functions/lib/` alól töltődik, amely jelenleg **legacy pathokat** tartalmaz. A fenti módosítások után **új build szükséges** (`npm ci && npm run build`) és **deploy** (régió: `europe-central2`).

---

# 🧪 Tesztállapot

1. **Rules runtime check (emulátor + valós projekt)**

   * Kliensről írható-e még `wallets/{uid}` vagy `users/{uid}/wallet`? → **NEM** (403).
   * `tickets` gyökér create? → **NEM** (403).
2. **Idempotencia**

   * `coin_trx` ugyanazzal a `transactionId`-val kétszer → **1** ledger sor, helyes wallet egyenleg.
3. **Finalizer E2E**

   * pending ticket → eredmény beérkezik → `CoinService.credit` hívás → **nincs duplázás**, helyes ledger bejegyzés.

---

# 🌍 Lokalizáció

* Nem érint fordítási kulcsokat. A ledger `type`/`source` mezőit a kliens a meglévő lokalizációs rétegen fordítja.

---

# 📎 Kapcsolódások

* **Bonus Engine** (`system_configs/bonus_rules`, `users/{uid}/bonus_state`): változatlan; a jóváírás továbbra is CF-en (SoT: wallet+ledger).
* **Leaderboard/Stats**: az olvasás `users/{uid}/wallet.coins` + `collectionGroup('tickets')` alapján marad.

---

## Fájlok, amelyeket ez a kör módosít

* `firebase.rules`
* `cloud_functions/src/match_finalizer.ts`
* `cloud_functions/coin_trx.logic.ts`

> Megjegyzés: a `cloud_functions/lib/**` fájlok **build-artifaktok**; szerkeszteni nem kell, de a fenti módosítások után **újra kell buildelni** és deployolni.
