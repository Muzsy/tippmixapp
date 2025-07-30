# Golden és Accessibility Tesztek Kezelése

Ez a dokumentum bemutatja, hogyan kell manuálisan frissíteni a golden screenshot baseline-okat és futtatni az accessibility auditot minden skin × light/dark kombinációra.

---

## 1. Golden tesztek frissítése

1. Győződj meg róla, hogy a `avoid-hard-coded-colors` lint szabály aktív a projektben (lásd `analysis_options.yaml`).
2. Futtasd a widget teszteket frissítés módban:

```bash
flutter test --update-goldens
```

3. A parancs létrehozza vagy frissíti a PNG baseline fájlokat a `test/goldens/` mappában.
4. Ellenőrizd vizuálisan a képeket, majd commitold őket a repositoryba.

## 2. Accessibility audit

Az alkalmazás témáinak kontrasztvizsgálatát az automatizált
`accessibility_test` csomag végzi. A `test/accessibility_test.dart` fájl
tartalmazza a megfelelő teszteket, amelyek minden skin light és dark módú
témájára lefutnak.

Futtasd a következő parancsot a teljes audithoz:

```bash
flutter test test/accessibility_test.dart
```

A teszt hibával tér vissza, ha bármely színkombináció nem felel meg a WCAG
előírásainak.

## 3. CI ellenőrzés

- A golden és accessibility teszteknek minden skin és mód esetén sikeresen kell lefutniuk.
- A CI pipeline csak akkor enged PR-t, ha minden teszt zöld.

---

Kövesd ezt a folyamatot minden alkalommal, amikor új skint vagy képernyőt vezetsz be.
