# 🔧 Környezeti konfiguráció betöltő (HU)

Ez a dokumentum bemutatja, hogyan töltik be a Cloud Functions a nem érzékeny beállításokat.

## Fájlok
- `env.settings.dev` – fejlesztői cron ütemezések, korlátozott sportlista, alacsony kvóta küszöb.
- `env.settings.prod` – éles cron ütemezések, minden sport, magas kvóta küszöb.

## Betöltő
A `functions/src/config.ts` a környezetből olvassa a `MODE` értékét (a `.env` csak lokálisan használatos), majd összefésüli az `env.settings.${MODE}` tartalmával.
A titkokat futásidőben a Google Secret Manager injektálja. A feltöltött `process.env` változókat `Config` néven exportálja a modulok számára.

## Cron változók

- `KICKOFF_TRACKER_CRON`
- `SCORE_POLL_CRON`
- `SCORE_SWEEP_CRON`

## Kvótafigyelő

- `QUOTA_WARN_AT` – minimális megmaradt OddsAPI kredit riasztás előtt
