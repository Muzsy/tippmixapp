# Backend Config – **env‑setup‑task**

## Kontextus

Az OddsAPI kulcs (ODDS\_API\_KEY) már szerepel a gyökér **.env** fájlban, a projekt pedig dev/prod környezetek közt eltérő, de *nem érzékeny* konfiguráció‑értékeket használ (cron stringek, sport‑szűrő, kvóta‑küszöb). Ezeket külön fájlba szeretnénk szétválasztani a tisztább CI‑deploy és gyorsabb fejlesztői váltás érdekében.

## Cél

> **Legyen két verziókövetett beállítás‑fájl**: `env.settings.dev` és `env.settings.prod`, valamint egy közös **config loader**, ami a `.env`‑ből betöltött *MODE* alapján automatikusan a megfelelő settings fájlt húzza be.

## Feladatok

* [ ] **env.settings.dev** létrehozása a dev értékekkel (ritkább cron, korlátozott sportlista).
* [ ] **env.settings.prod** létrehozása a prod értékekkel (sűrűbb cron, \* minden sport, magasabb kvóta‑küszöb).
* [ ] **Config loader** (`functions/src/config.ts`) – sorrend: 1) `.env` → 2) `env.settings.${MODE}`.
* [ ] **CI pipeline frissítés**: Cloud Functions deploy parancs vegye fel a `--set-env-vars=$(cat env.settings.prod | xargs)` részt.
* [ ] **Teszt**: unit‑teszt, ami `MODE=dev` mellett assert‑eli, hogy `process.env.SCORE_POLL_CRON === '0 */2 * * *'`.

## Acceptance Criteria / Done

* [ ] `npm run lint` és `npm test` hibamentes a *functions* mappára.
* [ ] A `config.ts` betölti a dev/prod settings‑eket helyesen (unit‑teszt zöld).
* [ ] CI deploy logban látszik, hogy a Cloud Function environment‑változói között szerepelnek a `SCORE_*`, `KICKOFF_TRACKER_CRON` stb.

## Hivatkozások

* Canvas → `/codex/goals/env-setup-task.yaml`  fileciteturn6file0
