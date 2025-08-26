# match-finalizer – v2 CloudEvent fix (ApiFootballResultProvider → Secret Manager)

## Kontextus

A `match_finalizer` Gen2 Cloud Function Eventarc → Cloud Run útvonalon kap Pub/Sub **CloudEvent**-et. A konténer indulása közben a `functions.config()` hívás miatt (v1 minta) a modul betöltésekor kivétel keletkezik, így a Functions Framework nem tud elindulni (healthcheck fail), és/vagy a v2 Pub/Sub provider már a handler előtt hibára fut (korábban `messageId` hiba).

## Ok

`cloud_functions/src/services/ApiFootballResultProvider.ts` importkor/létrehozáskor **v1-es** `functions.config()`-ot használ, ami v2-ben nem támogatott. A kulcsot (API\_FOOTBALL\_KEY) Secret Manageren/ENV-en keresztül kell átadni, és **nem** importkor kiolvasni v1 API-val.

## Megoldás

1. **Tüntessük el** a `functions.config()` használatát a providerből.
2. A kulcsot a `global.ts`-ben definiált `defineSecret('API_FOOTBALL_KEY')` segítségével olvassuk ki és **paraméterként adjuk át** a providernek a `match_finalizer` modulban.

## Elfogadási kritériumok

* A konténer elindul; a `match_finalizer.start` saját log megjelenik.
* Nincs több `functions.config()` hiba és nincs `reading 'messageId'` TypeError a v2 providerből.
* A `ApiFootballResultProvider` **nem importál** `firebase-functions`-t.

## Manuális teszt

1. Deploy (Gen2, Pub/Sub topic `result-check`).
2. Publish tesztüzenet a topicra: `{ "job":"final-sweep", "test": true }`.
3. A Log Explorerben megjelenik a `match_finalizer.start` és a feldolgozás eredménye (`match_finalizer.done`).

## Megjegyzés

A részletes, géppel végrehajtható módosítások a **codex/goals/match-finalizer-v2-apifootball-config-fix.yaml** fájlban vannak, ez a vászon csak a háttérmagyarázat.
