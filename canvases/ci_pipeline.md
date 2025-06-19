## 🎯 Funkció

A `ci_pipeline` v2 célja, hogy minden Codex-generált vagy manuálisan hozzáadott funkció automatikusan ellenőrzésre kerüljön GitHub Actions segítségével. Mivel a Codex nem képes valós parancsokat futtatni vagy CI-pipeline-t indítani, kizárólag a szükséges workflow-fájl létrehozását és szerkesztését végzi el.

## 🧠 Fejlesztési részletek

### A Codex által létrehozandó pipeline fájl (`.github/workflows/ci.yaml`):

1. **Környezet előkészítésének deklarálása**

   * `actions/setup-flutter@v2`
   * stabil channel
   * cache használat

2. **Lint deklarálása**

   * `flutter analyze` parancs beillesztése
   * Pipeline szintaxisa tartalmazza a `fail-on-error` logikát

3. **Tesztfuttatás lefedettséggel**

   * `flutter test --coverage` deklaráció
   * `lcov.info` elmentése artefaktként

4. **ARB fájlok validálásának előkészítése**

   * A Codex hozzáadja a JSON validálás lépéseit (`lib/l10n/*.arb` fájlokra)
   * Codex csak a szintaxisellenőrzés parancsát illeszti be, de futtatni nem tudja

5. **Badge frissítés sablonja (opcionális)**

   * Coverage badge Markdown snippetet generál, de nem frissíti automatikusan

### Codex korlát:

* A Codex nem képes parancsokat futtatni vagy a CI státuszát ellenőrizni
* Csak fájlokat hoz létre vagy módosít (`.yaml`, `README.md`, stb.)

### Trigger deklaráció:

* Push esetén a `main` és `develop` branch-re
* PR esetén ezekre az ágakra

## 🧪 Tesztállapot

* A pipeline helyes létrejöttét emberi fejlesztőnek kell ellenőriznie push után
* A Codex által generált fájl szintaxisa CI-kompatibilis kell legyen

## 🌍 Lokalizáció

* A Codex beilleszti a `lib/l10n/app_*.arb` fájlok JSON validációs lépését a workflow-ba
* Emberi fejlesztő felelőssége a nyelvi fájlok validálása a CI futtatás során

## 📎 Kapcsolódások

* `test/` → tesztek csak a CI pipeline futtatása során aktiválódnak
* `lib/l10n/` → háromnyelvű ARB fájlok szintaxisa ellenőrizhető
* `pubspec.yaml` → a Codex ellenőrzi, hogy minden szükséges csomag be van-e húzva

Ez a v2 pipeline canvas deklarálja az automatizált ellenőrzések struktúráját, de a Codex csak a workflow fájl előkészítéséig jut el. A tényleges futtatás és hibakezelés GitHub CI környezetben történik.
