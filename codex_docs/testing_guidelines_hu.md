version: "2025-07-29"
last\_updated\_by: docs-bot
depends\_on: \[testing\_guidelines\_en.md]

# 🧪 Tesztelési irányelvek

> **Cél**
> Egységes tesztstratégia meghatározása a TippmixApphoz, hogy a Codex által generált kód megfeleljen a minőségi kapuknak és megakadályozza a regressziókat.

---

## 1. Tesztpiramis & felelősségek

| Réteg                | Felelős          | Mit tesztelünk                                       | Eszközök                                    |
| -------------------- | ---------------- | ---------------------------------------------------- | ------------------------------------------- |
| **Unit**             | A fájl gazdája   | Tiszta logika, utils, repositoryk, szervizek         | `flutter test`, `mocktail`, `riverpod_test` |
| **Widget**           | Funkció tulaja   | Állapot‑függő widgetek alap interakciókkal           | `flutter_test`, `WidgetTester`              |
| **Golden**           | Design & QA      | Pixel‑pontos megjelenés képernyőnként és nyelvenként | `golden_toolkit`, `screen_matches_golden()` |
| **Integráció / E2E** | QA automatizálás | Kritikus folyamatok képernyők és pluginek között     | `integration_test`, Firebase emulátor       |

### Lefedettségi cél

* **Unit + widget tesztek együtt ≥ 80 %** sorkimaradás csomagonként (CI ellenőrzi).
* A Golden és E2E tesztek **kiegészítők**; nem számítanak bele a százalékba.

---

## 2. Könyvtár- és névkonvenciók

```
test/
  unit/
    <funkció>/
      <file>_test.dart
  widget/
    <képernyő>_test.dart
  golden/
    <képernyő>_<nyelv>.png
  integration/
    <folyamat>_test.dart
```

* Minden tesztfájl **snake\_case**.
* Golden baseline‑ok a `test/golden/baseline/` alatt vannak, Gitben verziózva.

---

## 3. Mockok & fixek

* **mocktail** könnyű stubokhoz; Mockito kerülendő.
* Fake implementációk **provider override**-dal (Riverpod).
* JSON fixek a `test/fixtures/` mappában, `FixtureReader` helperrel.

---

## 4. CI lépések (`.github/workflows/ci.yaml`)

1. `flutter pub get`
2. `flutter analyze --fatal-infos`
3. `flutter test --coverage`
4. `dart run coverage:format_coverage` → fail, ha < 80 %
5. `flutter_a11y --min-contrast 4.5`
6. `flutter test --tags=golden` (renderel & összehasonlít)
7. `flutter drive --driver integration_test/driver.dart -d macos` (headless)

Bármely hiba megszakítja a pipeline-t.

---

## 5. Akadálymentesség & globalizáció

* Golden tesztek **hu/en/de** nyelveken futnak.
* `flutter_a11y` ellenőrzi a kontrasztot és a tappolható méretet.

---

## 6. Gyors ellenőrző lista merge előtt

| ✅ Ellenőrizd             | Parancs                                              |
| ------------------------ | ---------------------------------------------------- |
| Tesztek futnak lokálisan | `flutter test --coverage`                            |
| Lefedettség ≥ 80 %       | `genhtml coverage/lcov.info --summary`               |
| Új golden elfogadva      | `golden_toolkit --update-goldens` design review után |
| Integrációs flow zöld    | `flutter drive ...`                                  |

---

## Változásnapló

| Dátum      | Szerző   | Megjegyzés                 |
| ---------- | -------- | -------------------------- |
| 2025-07-29 | docs-bot | Első egyesített irányelvek |
