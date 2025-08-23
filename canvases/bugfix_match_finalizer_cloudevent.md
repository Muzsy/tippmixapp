# 🎯 Funkció

A `match_finalizer` Pub/Sub eseményre induló Gen2 Cloud Function (régió: `europe-central2`) CloudEvent formátumú üzeneteket fogad a `result-check` topikról. A feladata a pending szelvények feldolgozása (eredmények lekérése, tippek kiértékelése, státusz és payout frissítése), valamint a tranzakciók idempotens jóváírása.

# 🧠 Fejlesztési részletek

* **Aktuális állapot (forrás a feltöltött tippmixapp.zip alapján):**

  * `cloud_functions/global.ts` regionális és secret binding globálisan beállítva: `europe-central2`, `API_FOOTBALL_KEY`.
  * `cloud_functions/index.ts` a `firebase-functions/v2/pubsub` **onMessagePublished** API-t használja és a feldolgozást a `src/match_finalizer.ts` exportált `match_finalizer` függvényére delegálja.
  * `cloud_functions/src/match_finalizer.ts` a handler **PubSubMessage** szerű objektumot vár (`{ data?: string; attributes?: Record<string,string>; }`), base64 payload → JSON parse, tippek kiértékelése, Firestore tranzakció.
  * `cloud_functions/package.json` főbelépő: `lib/index.js`, `firebase-functions` jelenleg ^6.4.0.
* **Probléma:** a Log Explorerben tömeges `Cannot read properties of undefined (reading 'messageId')` sorok jelentek meg korábban. Ez a **CloudEvent vs. régi (message, context)** szignatúrák közti inkompatibilitás tünete a v2 Pub/Sub adapterben.
* **Célzott fix:** az `index.ts`-ben a CloudEvent típus egyértelmű annotálása, és a handler elején védő log + early return, így a callbackünk csak akkor fut, ha ténylegesen van `event.data.message`. A delegated `src/match_finalizer.ts` változatlanul **PubSubMessage**-t kap (a wrapper állítja elő).

# 🧪 Tesztállapot

* A funkcióhoz jelenleg nincs stabil end‑to‑end teszt, a CI egyes tesztek futtatását ideiglenesen letiltotta. Lokális validációhoz javasolt:

  1. `npm ci && npm run build` a `cloud_functions` mappában,
  2. manuális publish: `gcloud pubsub topics publish projects/tippmix-dev/topics/result-check --message='{"job":"final-sweep"}'`,
  3. log ellenőrzés: `gcloud functions logs read match_finalizer --gen2 --region=europe-central2 --limit=50`.

# 🌍 Lokalizáció

* Backend szinten technikai kulcsokkal dolgozunk (pl. `status: "pending|won|lost|void"`). Felhasználói üzenetek lokalizációja kliensen történik; a backend csak technikai logokat ír.

# 📎 Kapcsolódások

* **Firestore** (tickets, tranzakciók), **Pub/Sub** (`result-check`), **Cloud Functions Gen2/Cloud Run**, **Secret Manager** (API\_FOOTBALL\_KEY), **OddsAPI/API-Football** adapter a `src/services` alatt. A régió mindenütt `europe-central2`.

# ⚠️ Hibák és hiányosságok

* Régi naplókban `Cannot read ... messageId` – CloudEvent szignatúra és adapter-mismatch.
* Log Explorerben sokszor rossz resource‑on keresték: Gen2 logok **cloud\_run\_revision** alatt.

# 🚀 Fejlesztési javaslatok

1. **Típusos CloudEvent annotáció** az `index.ts`-ben + védő ellenőrzés.
2. **Mentett Log Explorer lekérdezés** a `match-finalizer` Cloud Run service-re.
3. (Opc.) CI‑ben minimál „füstteszt”: egy száraz publish és 1 db elvárt log sorra grep.
