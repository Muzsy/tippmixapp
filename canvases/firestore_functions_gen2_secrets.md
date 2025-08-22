# Step 1 – Functions Gen2 + Secret Manager bekötés

**Cél:**

* Minden érintett Cloud Function gen2 (v2) API-t használjon.
* API\_FOOTBALL\_KEY a Google Secret Managerből érkezzen (v2 secret binding), ne .runtimeconfig / kézi env.
* Régió egységesítése: `europe-central2`.
* Ütemezett job (daily\_bonus) migrálása `v2/scheduler`-re.

**Érintett fájlok:**

* `cloud_functions/index.ts` – globális v2 beállítások, secret binding a `match_finalizer`-hez.
* `cloud_functions/src/daily_bonus.ts` – gen1 → gen2 scheduler migráció, régió egységesítés.
* (Megjegyzés) `cloud_functions/src/services/ApiFootballResultProvider.ts` már támogatja a `process.env.API_FOOTBALL_KEY`-et, így a v2 secret binding után működni fog.

**Mi változik röviden:**

* `index.ts`: `setGlobalOptions({ region: 'europe-central2' })`; `defineSecret('API_FOOTBALL_KEY')`; `onMessagePublished({ topic, secrets: [...] }, handler)`.
* `daily_bonus.ts`: `functions.pubsub.schedule(...).onRun(...)` helyett `onSchedule({ schedule, timeZone }, handler)`; régió beállítása v2-vel.

**Telepítés / futtatás (helyben / CI):**

* Node 18/20 környezet.
* `cd cloud_functions && npm ci && npm run build && npm test`
* Deploy (példa): `firebase deploy --only functions` (ha Firebase CLI-t használsz) vagy `gcloud beta functions deploy` a gen2-nek megfelelően a projekt beállításai szerint.

**Secret Manager előfeltétel:**

* Secret: `API_FOOTBALL_KEY` (már létrehozva a Console-ban – a megrendelő jelezte).
* Jogosultság: a Functions runtime service account kapjon **Secret Manager Secret Accessor** (roles/secretmanager.secretAccessor) jogosultságot a titokra.

**Megjegyzések a kódhoz:**

* `ApiFootballResultProvider` a `process.env.API_FOOTBALL_KEY`-et olvassa (vagy fallback `functions.config()`), a v2 secret binding ezt környezeti változóként injektálja.
* `.runtimeconfig.json` már nem szükséges a kulcshoz, a titok a bindingon keresztül kerül be.

**QA checklist (Step 1):**

* [ ] `npm run build` hibátlan.
* [ ] `npm test` zöld (e2e ha használod: `npm run e2e`).
* [ ] `match_finalizer` logokban nincs „Missing API\_FOOTBALL\_KEY”.
* [ ] `daily_bonus` fut a v2 schedulerrel (logokban látszik), és csak egyszer fut naponta.
* [ ] Régió: minden v2 trigger `europe-central2`-ben jelenik meg a Console-ban.
