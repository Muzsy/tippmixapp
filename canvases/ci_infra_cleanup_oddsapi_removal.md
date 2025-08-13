# CI/Infra tisztítás – OddsAPI kivezetés (P0)

🎯 **Funkció**

* Az OddsAPI‑hoz kötődő **összes** kód-, CI-, secret‑ és doksi‑maradék biztonságos kivezetése.
* A pipeline és a környezet egységesítése **API‑Football** köré (secrets, env, mockok, tesztek).
* Cél: zöld **CI futás** (Functions + Flutter), külső hívások nélkül, és nulla OddsAPI‑referencia a repo teljes tartományában.

🧠 **Fejlesztési részletek**

* **Keresési halmaz**: teljes repo, de kiemelten: `/cloud_functions`, `/functions`, `/lib`, `/test`, `/android`, `/ios`, `/.github/workflows`, `/docs`, `/codex_docs`, `tmp/`, `env.*`, `.env*`, `firebase.json`, `firebaserc`.
* **Eltávolítandó/átnevezendő elemek**:

  * Környezeti kulcsok: `ODDS_API_KEY`, `ODDSAPI_*`, `ODDS_*` → törlés.
  * Csomagok/SDK: OddAPI‑specifikus kliensek, utilok, mockok.
  * CI secrets: GitHub Actions‑ban és helyi `tmp/env.yaml`‑ban.
  * Doksik: README/Docs szakaszok, amelyek OddsAPI‑t említenek.
  * Build step: bármely pipeline‑lépés, ami OddsAPI reachability‑t tesztel.
* **Egységesítés API‑Football‑ra**:

  * Secrets: `APIFOOTBALL_KEY`, opcionálisan `APIFOOTBALL_HOST` (RapidAPI vs. direct).
  * Emulátoros/jest futások: eredmény‑szolgáltató **mock** használata; nincs hálózati kimenet.
  * Régiók: Functions régió **europe‑central2** (konzisztens deploy).
* **Biztonság**: a kivezetés nem ronthatja el a meglévő flow‑kat (ticket create/finalize/payout). Minden törlés fehérlistás és diff‑el ellenőrzött.

🧪 **Tesztállapot**

* CI futtat: `npm ci && npm test` a `cloud_functions/` alatt; `flutter analyze && flutter test` a gyökérben.
* Kötelező zöld: widget tesztek (i18n), service tesztek, finalizer/payout unit tesztek.
* Smoke: emulátoros E2E (külön canvasban részletezve) opcionális, de ajánlott a merge‑hez.

🌍 **Lokalizáció**

* A kivezetés nem érinti az i18n resource‑okat; csak a dokumentációs szövegek frissülnek.
* Ha README/Docs többnyelvű, mindkét nyelven cserélni az OddsAPI említéseket API‑Football‑ra.

📎 **Kapcsolódások**

* Függ: `emulator_e2e_ticket_flow.md` (mock‑alapú E2E).
* Érinti: GitHub Actions workflow(k), Functions projekt (env/secrets), Flutter app build.
* Doksik: `Api Football Migration Plan.pdf`, `Codex Canvas Yaml Guide.pdf`.

**Elfogadási kritériumok**

* [ ] A repo **0** találatot ad `OddsAPI|ODDS_API_KEY|ODDSAPI` keresésre (kivéve changelog/archív).
* [ ] GitHub Actions minden ágon **zöld** (Functions + Flutter).
* [ ] A Functions tesztek **nem** végeznek hálózati hívást (jest mock aktív).
* [ ] Deploy/regió egységesítve (europe‑central2), titkok csak API‑Football‑ra vonatkoznak.
* [ ] README/Docs frissítve, kivezetési jegyzet kész.
