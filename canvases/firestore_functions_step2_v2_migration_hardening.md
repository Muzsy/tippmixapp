# CF – Step 2: v2 migráció + hardening (admin, log, értesítés, CI)

🎯 **Funkció**

* A meglevő v1 (Gen1) callable/identity/scheduler functionök migrálása **Gen2 (v2)** API‑ra.
* **Secret Manager** használat folytatása; egységes régió: `europe-central2` (globálisan).
* **Admin műveletek SoT‑kompatibilissé** tétele: `admin_coin_ops` → `CoinService` (wallet+ledger tranzakció, idempotencia).
* **log\_coin** ártalmatlanítása (admin‑only audit; ne írjon ledger‑t / egyenleget).
* **Értesítések user‑centrikus átstrukturálása**: `users/{uid}/notifications/{id}`.
* **CI tisztítás**: runtime config és kézi .env kivezetése (GSM az igazság forrása).

🧠 **Fejlesztési részletek**

* v2 importok: `firebase-functions/v2/https`, `v2/identity`, `v2/scheduler`, `v2/options`.
* Globális opciók: `setGlobalOptions({ region: 'europe-central2' })` az `index.ts` elején; Secret binding: `defineSecret('API_FOOTBALL_KEY')` és `secrets:[...]` a `match_finalizer`‑ben.
* `coin_trx`: v2 `onCall`; a meglévő idempotencia megmarad (ledger docId=`transactionId`).
* `onUserCreate`: v2 `onUserCreated` (wallet init változatlan).
* `daily_bonus`: v2 `onSchedule`; (később paging + Bonus Engine integráció Step 3‑ban).
* `admin_coin_ops`: v2 `onCall`; **tilos** közvetlenül `users/{uid}.coins`‑t írni; helyette `CoinService.credit/debit()` tranzakcióban és ledger sorral; admin‑claim ellenőrzés marad.
* `log_coin`: v2 `onCall`, **admin‑only**; ledger helyett `system_counters/coin_logs_legacy/logs/{transactionId}` (audit). Később teljes kivezetés.
* `friend_request`: régió duplikáció eltávolítása (globális options miatt), **értesítések user‑ágra**: `users/{toUid}/notifications/{id}`.
* `deploy.yml`: töröljük a `functions:config:set/get` és `.env` írást.

🧪 **Tesztállapot**

* Unit: build zöld (`npm ci && npm run build`), jest fut.
* E2E: `coin_trx` kétszeri hívás azonos `transactionId`‑vel → 2. hívás no‑op; `onUserCreate` fut új userre; `daily_bonus` v2 időzítő logban látszik; `admin_coin_ops` könyvel és ledger‑t ír; `log_coin` csak adminnal hívható és **nem** ír ledger‑t; `friend_request` értesítés a `users/{uid}/notifications` alá kerül.

🌍 **Lokalizáció**

* Nincs UI szöveg módosítás ebben a lépésben. (A ledger `type/source` kulcsait a kliens oldali i18n kezeli.)

📎 **Kapcsolódások**

* Bonus Engine és user‑centrikus architektúra: wallet+ledger SoT, idempotencia (lásd: `/docs`, `/codex_docs`, és a kapcsolódó PDF‑ek). A mostani lépés a Step 3 bónuszlogika‑reform előfeltétele.
