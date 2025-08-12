# API-Football átállás – Backend ResultProvider előkészítés

## Kontextus

Az alkalmazás eddig az OddsAPI-t használta a mérkőzéseredményekhez (Cloud Functions: `ResultProvider.ts` → `match_finalizer.ts`). A Firestore jelenleg üres (nincsenek `tickets` / `matches`), így nincs szükség ID-migrációra vagy dual-runra. Első lépésként bevezetünk egy új, API-Football alapú providert **bekötés nélkül** (biztonságos előkészítés), majd külön vászonban végezzük el a teljes átállítást és a régi kód kivezetését.

## Cél (Goal)

Új `ApiFootballResultProvider` létrehozása a Cloud Functions kódban, amely az API‑Football `fixtures` végpontjáról olvas, és visszaadja a `match_finalizer` által igényelt alap statust/eredmény mezőket. Ebben a vászonban **még nem** kapcsoljuk be a használatát (nincs viselkedésváltozás).

## Feladatok

* [ ] Új fájl: `cloud_functions/src/services/ApiFootballResultProvider.ts` (fetch alapú kliens, `API_FOOTBALL_KEY` olvasása env-ből)
* [ ] Alap metódus: `getScores(eventIds: string[]): Promise<any[]>` – lekérdezés fixture ID-k szerint
* [ ] Map-elés: status (pl. `NS/1H/HT/2H/FT`), gólszámok, győztes csapat azonosító (ha elérhető)
* [ ] Teszt stub: `cloud_functions/test/apiFootballResultProvider.test.ts` – sikeres válasz parszolása (mock)
* [ ] CI futtatás: `npm test` a functions mappában
* [ ] Doksi frissítés a kulcsról: `API_FOOTBALL_KEY` szükséges (GitHub Secrets + Functions config)

## Acceptance Criteria / Done Definition

* [ ] A repo-ban létezik az új `ApiFootballResultProvider.ts` és sikeresen lefordul (Node 18+ `fetch` használat)
* [ ] Teszt stub lefut (legalább 1 pozitív parse teszt mockolt válasszal)
* [ ] `flutter analyze` és a Functions TypeScript build hibamentes
* [ ] **Semmilyen** meglévő viselkedés nem változik (nincs bekötve a `match_finalizer`-be)
* [ ] Doksiban rögzítettük az `API_FOOTBALL_KEY` beállítását

## Hivatkozások

* Canvas → `/codex/goals/api_football_backend_provider.yaml`
* Átállási terv: `Api Football Migration Plan.pdf`
* Codex szabályok: `Codex Canvas Yaml Guide.pdf`

---

### 🎯 Funkció

API‑Football alapú **új** eredmény-szolgáltató fájl hozzáadása (előfutár a teljes kiváltáshoz), kód-bekötés nélkül.

### 🧠 Fejlesztési részletek

* Könyvtár: `cloud_functions/src/services/`
* Új fájl tartalma: natív `fetch` (Node 18), fejléc: `x-apisports-key: <API_FOOTBALL_KEY>`
* Endpoint: `https://v3.football.api-sports.io/fixtures?id={fixtureId}` (egyszerűsített, egyenkénti lekérés; batch-optimalizálás külön vászonban)
* Visszatérési shape: minimalista (status.short, goals.home, goals.away, winnerId ha elérhető)
* **Tiltott fájlokhoz nem nyúlunk** (`android/`, `ios/`, `pubspec.yaml`, stb.)

### 🧪 Tesztállapot

* Új unit teszt stub a providerhez mockolt JSON-nal; fut a CI-ben
* Hibautak (401/429) csak TODO-ként jelölve; bekötés után külön vászonban kezeljük

### 🌍 Lokalizáció

* Nincs UI-szöveg; lokaliációs fájlokhoz nem nyúlunk

### 📎 Kapcsolódások

* `cloud_functions/src/match_finalizer.ts` – **nem módosul** ebben a vászonban
* Következő vászon: "Backend cutover – match\_finalizer bekötése és OddsAPI kivezetése"
