# 🎯 Funkció

A `match_finalizer` Pub/Sub eseményre induló **Gen2 Cloud Function** (régió: `europe-central2`) a `result-check` topicról érkező **CloudEvent** üzeneteket dolgozza fel. Feladata a `pending` szelvények kiértékelése (külső eredményforrás lekérdezése), a szelvény státuszának frissítése és az idempotens jóváírás a wallet/ledger felé.

# 🧠 Fejlesztési részletek (aktuális állapot + hiba oka)

* A feltöltött logok alapján a függvény **Gen2 / CloudEvent** szignatúrával fut (FUNCTION\_SIGNATURE\_TYPE=cloudevent).
* A handler a belépéskor a `firebase-functions` v2 Pub/Sub adapterben hibára fut: `Cannot read properties of undefined (reading 'messageId')` – ez klasszikus **szignatúra‑mismatch** (Gen1 `(message, context)` elvárás egy Gen2 CloudEvent mellett).
* A megoldás: az `index.ts`-ben a `onMessagePublished` callback **CloudEvent** típusjelölése, védő log/guard és a beérkező üzenet **PubSubMessage**-re való leképezése, majd delegálás a meglévő `src/match_finalizer.ts` handlerre.
* A `package.json`-ban opcionális `"engines": { "node": ">=20" }` felvétel (ha még nincs), hogy a CI/Build környezet is Node 20-ra igazodjon.

# 🧪 Tesztállapot

* Kézi füstteszt: `gcloud pubsub topics publish projects/tippmix-dev/topics/result-check --message='{"job":"final-sweep"}'` majd `gcloud functions logs read match_finalizer --gen2 --region=europe-central2 --limit=50`.
* Log Explorerben **cloud\_run\_revision** resource alatt, service\_name = `match-finalizer`.

# 🌍 Lokalizáció

* Backend csak technikai logokat ír. Felhasználói üzenetek lokalizációja kliensen.

# 📎 Kapcsolódások

* **Pub/Sub** (`result-check`), **Eventarc**, **Cloud Functions Gen2/Cloud Run**, **Firestore**, **Secret Manager** (API kulcsok), külső eredményforrás adapter.

# ⚠️ Hibák és hiányosságok

* Szignatúra‑mismatch miatti adapter‑hiba a belépéskor → nem jut el a saját kódig.
* Log Explorerben korábban rossz resource‑ra szűrés (Gen2 → Cloud Run).

# 🚀 Fejlesztési javaslatok

1. `index.ts` CloudEvent‑kompatibilis wrapper + guard + részletes belépési logok.
2. (Opció) `package.json` engines beállítás Node 20-ra.
3. CI‑ben build + célzott redeploy csak a `match_finalizer`-re, majd füstteszt.
