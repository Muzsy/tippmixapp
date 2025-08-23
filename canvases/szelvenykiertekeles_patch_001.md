# Cél

Stabilizálni a szelvénykiértékelési folyamatot az új (Firebase-refaktor utáni) adatszerkezethez igazítva, és eltávolított OddsAPI-azonosítók helyett az **API-Football** alapú eredménylekérdezést véglegesíteni. A patchek csak a szükséges mértékű, pontos módosításokat tartalmazzák a *most feltöltött* `tippmixapp.zip` kódjára illesztve.

# Változások röviden

1. **API-Football integráció véglegesítése**: implementáljuk a `findFixtureIdByMeta` függvényt (eddig helykitöltő/`return null`) a dátum + csapatnevek alapján történő azonosításhoz.
2. **H2H evaluator robusztusabbá tétele**: normalizáljuk a választásokat (HOME/AWAY/DRAW ↔ csapatnevek/„Draw”) és kis/nagybetű-kezelés.
3. **match\_finalizer finomhangolás**: többes szelvény (`tips[]`) esetén az eseményazonosítók feloldása API‑Football `fixture` ID-re; void (canceled) esetének kezelése; naplózás pontosítása.
4. **CI/CD érintés (nincs újfajta átírás)**: a meglévő, már SA‑alapú deploy marad; nem változtatjuk a pipeline szerkezetét.

# Érintett fájlok

* `cloud_functions/src/services/ApiFootballResultProvider.ts`
* `cloud_functions/src/evaluators/H2H.ts`
* `cloud_functions/src/match_finalizer.ts`

# Megjegyzések

* A patch-ek **nem** érnek hozzá a `package.json`/`tsconfig.json` fájlokhoz, a jelenlegi beállítások megfelelők (Node 20 kompatibilis publish, `lib/` kimenet, tesztek külön).
* A változtatások visszafelé kompatibilisek az új `tickets` sémával (multi-tip `tips[]`).

---

## 1) API-Football – `findFixtureIdByMeta` implementálása

**Miért kell?** A korábbi OddsAPI‑alapú azonosítókat (oddsapis ID-k) eltávolítottuk. Az eseményfeloldás jelenleg visszatér `null`-lal, ami *pending* állapotban tarthatja a tippeket. Bevezetjük a dátum + csapatnév alapú keresést.

**Mit csinál a megoldás?**

* `GET /fixtures?date=YYYY-MM-DD&team=<id|name>` lekérdezésekkel (két lekérdezés: home és away) leszűkítjük a jelölteket.
* A metában szereplő `eventName` ("Home - Away") és `startTime` alapján pontos egyezést keresünk.
* Siker esetén visszaadjuk az `id` (fixtureId) értéket; különben `null`.

**Biztonság:** API-kulcsot az `API_FOOTBALL_KEY` env‑ből (vagy `functions.config().apifootball.key`) olvassuk.

---

## 2) H2H evaluator – normalizálás

* A felhasználói választás és a szolgáltatói eredmény kis/nagybetűtől független összevetése.
* A `Draw` ↔ `DRAW` ↔ döntetlen eseteinek egységes kezelése.
* Ha nincs `winner`, de van `scores`, a gólok alapján számolunk nyertest – továbbra is támogatott.

---

## 3) match\_finalizer – többes tippek és void kezelés

* A `tips[].eventId` → (fixtureId) feloldás `findFixtureIdByMeta` segítségével, ha az adott tiphez nincs már ismert `fixtureId`.
* Ha az eredmény szolgáltató **canceled/void** állapotot jelez, a tipp `result = 'void'` lesz, a szelvény kifizetés kalkuláció ennek megfelelően kezeli.
* Naplózás: batch/attempt adatok pontosítása.

---

## Tesztek / mitigáció

* A változtatások nem érintik a jelenlegi buildet; a CI a `lint + build` lépésekkel zöld marad.
* Külön (nem kötelező) E2E lefedéshez az emulatoros futtatás később visszakapcsolható.

---

## Következő lépések

1. Alkalmazd az alábbi diff‑eket (lásd YAML‑ban).
2. `npm ci && npm run build` a `cloud_functions/` mappában.
3. Deploy: meglévő GitHub Actions `Deploy Backend` workflow futtatása (nem kell módosítani).
4. Ellenőrzés: `tickets` kollekcióban a pending szelvények `processedAt`/`status` frissülése és a `ledger` bejegyzések (void esetben nincs nyereség hozzáírás).

---

**Kapcsolódó vászon/YAML**: A konkrét, pontos diff-eket lásd a hozzá tartozó Codex YAML fájlban (név: `codex/goals/szelvenykiertekeles_patch_001.yaml`). Ez a vászon kiegészítő magyarázatként szolgál a YAML‑ban hivatkozott patch‑ekhez.
