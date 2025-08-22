# 🧩 API-Football kulcs kezelése – Lazy read + fallback

## 🎯 Funkció

A Cloud Functions forráskód elemzése a deploy során ne hasaljon el `Missing API_FOOTBALL_KEY` hibával. A kulcs beolvasása legyen **fallbackos** (`process.env` → `functions.config()`), és **lusta validációval** (ne modulbetöltéskor dobjon, csak a tényleges hívás előtt).

## 🧠 Fejlesztési részletek

* Érintett fájl: `cloud_functions/src/services/ApiFootballResultProvider.ts`
* Változtatások:

  * `import * as functions from 'firebase-functions'` hozzáadása.
  * Konstruktor: `process.env.API_FOOTBALL_KEY` **vagy** `functions.config().apifootball?.key` használata.
  * Azonnali `throw` eltávolítása a konstruktorból (top-level init helyett).
  * **Lazy check**: az első éles hívás (\`getScores\`) elején ellenőrizzük a kulcs meglétét.
* Deploy ellenőrzés: a jelenlegi `deploy.yml` már beállítja a kulcsot (`functions:config:set apifootball.key=…`) és exportálja a lokális elemzéshez (`functions:config:get > cloud_functions/.runtimeconfig.json`).

## 🧪 Tesztállapot

* Egységteszt nem érintett.
* Gyors füstteszt: a `firebase-tools` „Loading and analyzing source code” fázisa nem dob többé `Missing API_FOOTBALL_KEY` hibát.

## 🌍 Lokalizáció

* Nincs user-facing szöveg.

## 📎 Kapcsolódások

* Kapcsolódó workflow: `.github/workflows/deploy.yml` – a projekt runtime config beállítása és exportja (`apifootball.key`).
* A vászonra hivatkozó Codex YAML: `codex/goals/canvases/fill_canvas_svc_api_football_key_lazy_read.yaml`.
