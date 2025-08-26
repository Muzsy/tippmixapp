# match-finalizer – v2 CloudEvent + Secret binding fix (ApiFootball → Secret Manager)

## Kontextus

A `match_finalizer` Gen2 (Eventarc→Cloud Run) Pub/Sub CloudEventet fogad. A legutóbbi diag-log alapján a konténer már elindul, de a futás elején figyelmeztet:

* `No value found for secret parameter "API_FOOTBALL_KEY". A function can only access a secret if you include the secret in the function's dependency array.`

A buildelt `lib/index.js` **deklarálja** a secreteket (global options + function options), viszont a `ApiFootballResultProvider` **nem kapja meg** a kulcsot, és még v1-es `functions.config()` fallbacket is tartalmaz.

## Cél

* A `ApiFootballResultProvider` **ne** használjon `functions.config()`-ot.
* A `match_finalizer` **átadja** a Secret Managerből (`API_FOOTBALL_KEY`) a kulcsot a providernek (fallback: `process.env.API_FOOTBALL_KEY`).
* Marad a v2 `onMessagePublished` CloudEvent (topic: `result-check`).

## Elfogadási kritériumok

* A `match_finalizer.start` saját log megjelenik hiba nélkül.
* Nem jelenik meg többé a `No value found for secret parameter` üzenet.
* Nincs `TypeError: reading 'messageId'` hiba a v2 providerből.

## Megjegyzés

A **konkrét, mostani ZIP-hez igazított diffek** a `codex/goals/match-finalizer-v2-apifootball-secret-binding.yaml` fájlban találhatók. Ez a vászon a háttérmagyarázat és az elvárások összefoglalója.
