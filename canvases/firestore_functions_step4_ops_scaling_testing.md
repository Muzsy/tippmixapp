# CF – Step 4: Üzemeltetés, skálázás, tesztelés (paging, retry, log, index, kivezetések)

🎯 **Cél**

* Napi bónusz **pagingelt** futtatása (nagy userbázisnál is stabil), strukturált logokkal.
* **Retry** engedélyezése a `match_finalizer`‑en (Pub/Sub), jobb hibatűrés.
* **Strukturált logging** bevezetése a kritikus pontokon (`match_finalizer`, `coin_trx`, `daily_bonus`).
* **Indexek**: `collectionGroup('ledger')` – `type+createdAt` kompozit index jsonban.
* **Legacy kivezetés**: `log_coin` export eltávolítása (deployból kivesz), külön operációs parancs a végleges törlésre.
* **Alap e2e tesztek** a bónusz idempotencia/race esetre (jest + emulator), legalább smoke szinten.

📦 **Érintett fájlok**

* `cloud_functions/src/daily_bonus.ts` – paging + logger.
* `cloud_functions/index.ts` – Pub/Sub `retry: true`, logger, `log_coin` export kivezetés.
* `cloud_functions/src/match_finalizer.ts` – strukturált logok try/catch‑ben.
* `cloud_functions/coin_trx.logic.ts` – strukturált logok siker/hiba esetén.
* `firestore.indexes.json` – kompozit index (ledger cg).
* `cloud_functions/test/bonus_claim.e2e.test.ts` – smoke/idempotencia/race tesztek (emulatorra kész).

🧠 **Megvalósítási megjegyzések**

* Paging: Firestore `limit(N)` + `startAfter(lastDoc)` ciklus; N=200 (állítható). Kreditálás továbbra is `CoinService`‑en át, per user tranzakció.
* Retry: v2 Pub/Sub trigger opcióban `retry: true` – dead‑letter nélkül is növeli a siker esélyét átmeneti hibáknál.
* Logger: v2‑ben `import * as logger from 'firebase-functions/logger'`.
* Index: `firestore.indexes.json` deklaratív fájl, `firebase deploy --only firestore:indexes` veszi fel.
* Kivezetés: export törlése → új deploy már nem frissíti a régi functiont. **Végleges törléshez** egyszeri parancs: `firebase functions:delete log_coin --region=europe-central2 --force`.

🧪 **QA / teszt**

* `npm run build` zöld.
* Emulatoron: `claim_daily_bonus` kétszer → második hívás elutasít (cooldown/idempotencia), ledger csak 1 új sor.
* Párhuzamos 5 hívás `claim_daily_bonus`‑ra → legfeljebb 1 sikeres (lock miatt), loggerben látszanak a kísérletek.
* `daily_bonus` paging működik: logban létszám/oldalak száma.
* `match_finalizer` hibánál: logger error + Pub/Sub retry (ismételt futás logja látszik).

📎 **Hivatkozások**

* Lásd előző vásznak: Step1 (Gen2+Secrets), Step2 (v2 migráció + hardening), Step3 (Bonus Engine + checksum). A mostani lépés ezek üzemeltetési/robosztussági kiegészítése.
