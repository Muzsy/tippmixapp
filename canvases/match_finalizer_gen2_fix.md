# Match finalizer – Gen2/Cloud Run fix (GCLOUD\_PROJECT hiba megszüntetése)

## 🎯 Funkció

A `match_finalizer` Pub/Sub alapú Cloud Function feladata a jegyek (ticketek) kiértékelésének lezárása: eredmények lekérése (API‑Football), tippek kiértékelése, kifizetés számítás (payout) és a Firestore frissítése.

## 🧠 Fejlesztési részletek

**Jelenlegi hiba:**
`Error: process.env.GCLOUD_PROJECT is not set.` — a logok szerint a Gen2/Cloud Run környezetben a `firebase-functions` **v1** `pubsub` provider már **modulbetöltéskor** olvassa a `GCLOUD_PROJECT` változót. Gen2 alatt ez nem garantált, ezért a handler futása előtt elhasal.

**Ok:**
`cloud_functions/index.ts` v1 API-t használ:

```ts
import * as functions from 'firebase-functions';
...
export const match_finalizer = functions
  .region('europe-central2')
  .pubsub.topic('result-check')
  .onPublish(matchFinalizerHandler);
```

Ez a v1 útvonal a `firebase-functions/lib/v1/providers/pubsub.js` kódot húzza be, ami megköveteli a `GCLOUD_PROJECT`-et.

**Megoldás:**
Migrálunk **v2** API-ra (`firebase-functions/v2/pubsub`), ami **Gen2‑kompatibilis**, és nem függ a régi `GCLOUD_PROJECT` mintától. A `src/match_finalizer.ts` handler megtartása mellett egy **adapter**-t adunk az `index.ts`‑ben, amely a v2 CloudEvent‑ből a `data` és `attributes` mezőket a meglévő `PubSubMessage` szerkezetre alakítja.

**Változtatás lényege:**

* `firebase-functions` (v1) import ELTÁVOLÍTVA az `index.ts`‑ből.
* Helyette: `import { onMessagePublished } from 'firebase-functions/v2/pubsub'`.
* Új v2 trigger: `onMessagePublished('result-check', async (event) => { ... })`.
* Az `event.data.message` → `{ data, attributes }` átkonvertálása a meglévő `matchFinalizerHandler` számára.
* Régió: a projektben már használatban van a `setGlobalOptions({ region: 'europe-central2' })` (pl. `friend_request.ts`), ezért külön régióbeállítás nem szükséges; a kód ettől függetlenül Gen2‑safe.

**Miért jó ez?**

* Megszűnik a `GCLOUD_PROJECT` hiányából adódó crash.
* Nem kell környezeti változót injektálni.
* A meglévő TypeScript handler (üzleti logika) érintetlen marad.

## 🧪 Tesztállapot

1. **Build**: `cd cloud_functions && npm ci && npm run build`.
2. **Deploy**: Firebase CLI‑vel (ajánlott, mivel több func is van):

   ```bash
   firebase deploy --only functions:match_finalizer --project tippmix-dev --region europe-central2
   ```

   (Ha gcloud‑dal mész, nincs szükség `--set-env-vars` vagy `--env-vars-file` hackre.)
3. **Smoke test**: küldj egy teszt üzenetet a `result-check` topicra:

   ```bash
   gcloud pubsub topics publish result-check \
     --project=tippmix-dev \
     --message='{"job":"final-sweep"}'
   ```
4. **Log ellenőrzés**: Logs Explorerben **nincs** többé `GCLOUD_PROJECT is not set`; helyette a `received job: final-sweep` és a ticket loop logok jelennek meg. Ellenőrizd, hogy a Firestore‑ban frissülnek‑e a státuszok/kifizetések.

## 🌍 Lokalizáció

Nincs felhasználói felülethez kötött változás. A logolás jelenleg angol; igény esetén egységesíthető magyarra (nem része ennek a fixnek).

## 📎 Kapcsolódások

* `cloud_functions/src/match_finalizer.ts` (meglévő handler, változatlan)
* `cloud_functions/src/services/ApiFootballResultProvider.ts` (eredményforrás)
* `cloud_functions/src/tickets/payout.ts` (payout kalkuláció)
* Firestore `tickets` és `users` kollekciók
* Pub/Sub topic: `result-check`

---

**Kockázat / visszagörgetés:** minimális. Ha bármi, a régi v1 import visszarakható, de Gen2 alatt újra előjönne a hiba. A v2‑re váltás a jelenlegi dependency‑kkel (firebase-functions ^5.x) támogatott.
