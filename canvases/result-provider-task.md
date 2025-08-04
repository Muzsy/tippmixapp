# Results API Adapter – **result-provider-task**

## Kontextus

A Cloud Function *match\_finalizer* az OddsAPI /scores végpontjából nyeri ki a meccs-eredményeket. Ehhez írunk egy **ResultProvider** modult, amely

1. Prod módban HTTP-n hívja az OddsAPI-t, 40-es batch-ekben.
2. Dev módban (és/vagy ha `USE_MOCK_SCORES=true`) a `mock_scores/*.json` fájlokat olvassa be, hogy kvótakímélő teszteket fussunk.

## Feladatok

* [ ] `functions/src/services/ResultProvider.ts` – implementáció + interface.
* [ ] `mock_scores/oddsApiSample.json` – minta válasz egy completed meccsre.
* [ ] `functions/test/ResultProvider.spec.ts` – unit-teszt (dev‑mock útvonal).
* [ ] Nem igényel külső lib‑et; Node ≥18 globális **fetch** API-t használunk.

## Acceptance Criteria

* Jest-teszt zöld (`MODE=dev` + `USE_MOCK_SCORES=true`).
* Ha `eventIds.length = 61`, a provider 2 API-hívást készít (chunk 40/21) – mocked fetch‑spy a later integration testben.
* Throwing 404/429‑et továbbadja.

## Függőségek

* **scheduler-jobs-task** – nem blokkoló, de sorrendben ez után jön.
