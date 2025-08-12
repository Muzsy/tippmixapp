# API-Football átállás – Backend cutover & OddsAPI kivezetés (Cloud Functions)

## Kontextus

A `cloud_functions/src/match_finalizer.ts` jelenleg a `ResultProvider` (OddsAPI) osztályt használja. Az új `ApiFootballResultProvider.ts` már létezik a projektben, de **nincs bekötve**. Firestore üres (nincs élő `tickets`/`matches` adat), ezért biztonságosan válthatunk.

## Cél (Goal)

A `match_finalizer` bekötése az **API‑Football** alapú providerre, az **OddsAPI** függőség és mock-ok **eltávolítása** a src-ből. Funkcionális változás: a ticket státuszok API‑Football adatokból frissülnek.

## Feladatok

* [ ] `match_finalizer.ts` import és példányosítás átállítása: `ResultProvider` → `ApiFootballResultProvider`
* [ ] `cloud_functions/src/services/ResultProvider.ts` törlése (OddsAPI adapter)
* [ ] `cloud_functions/mock_scores/oddsApiSample.json` törlése
* [ ] Build & test: Cloud Functions TypeScript build és unit tesztek futtatása
* [ ] Doksi: rövid migrációs jegyzet az OddsAPI kivezetéséről

## Acceptance Criteria / Done Definition

* [ ] A `match_finalizer` futás közben **nem importál** és **nem példányosít** OddsAPI-s kódot
* [ ] A `cloud_functions/src/services/ResultProvider.ts` és a `mock_scores/oddsApiSample.json` **nincs a repo-ban**
* [ ] `npm run build` sikeres a `cloud_functions` mappában, `npm test` zöld
* [ ] A projektben (src-ben) nem marad `ODDS_API_KEY`/`the-odds-api` hivatkozás
* [ ] Doksiban rögzítve a kivezetés

## Hivatkozások

* Canvas → `/codex/goals/fill_canvas_api_football_backend_cutover.yaml`
* Előkészítő vászon: `api_football_backend_provider.md`
* Átállási terv: `Api Football Migration Plan.pdf`
* Codex szabályok: `Codex Canvas Yaml Guide.pdf`

---

### 🎯 Funkció

A `match_finalizer` **API‑Football** alapra állítása és az **OddsAPI** adapter/minták **eltávolítása** a forráskódból.

### 🧠 Fejlesztési részletek

* Érintett fájlok:

  * `cloud_functions/src/match_finalizer.ts` (import & provider példányosítás)
  * **törlés**: `cloud_functions/src/services/ResultProvider.ts`
  * **törlés**: `cloud_functions/mock_scores/oddsApiSample.json`
* Ne módosítsd a `lib/` (build) mappát; a tsc újragenerálja.
* `ApiFootballResultProvider` konstruktor az `API_FOOTBALL_KEY`-et olvassa (`process.env.API_FOOTBALL_KEY`).

### 🧪 Tesztállapot

* A korábbi vászonban létrehozott `apiFootballResultProvider` unit teszt fut.
* Ezen vászon végén `npm run build` és `npm test` zöld a `cloud_functions` könyvtárban.

### 🌍 Lokalizáció

* Nincs UI-változás, i18n nem érintett.

### 📎 Kapcsolódások

* `index.ts` → `match_finalizer` export változatlan
* Következő vászon: **Frontend** – `ApiFootballService` bekötése és OddsAPI front-end kód kivezetése
