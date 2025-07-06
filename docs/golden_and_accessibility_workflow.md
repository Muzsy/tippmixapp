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

1. Telepítsd az `accessibility_tools` csomagot, ha még nincs:

```bash
flutter pub global activate accessibility_tools
```

2. Futtasd az auditot az alkalmazásra:

```bash
flutter pub global run accessibility_tools:accessibility_tools --outfile a11y_report.html
```

3. A generált `a11y_report.html` fájlt nézd át, és győződj meg róla, hogy minden hiba javítva lett.
4. A riportot a projekt gyökerében, illetve a testkörnyezetben tárolhatod és commitolhatod.

## 3. CI ellenőrzés

- A golden és accessibility teszteknek minden skin és mód esetén sikeresen kell lefutniuk.
- A CI pipeline csak akkor enged PR-t, ha minden teszt zöld.

---

Kövesd ezt a folyamatot minden alkalommal, amikor új skint vagy képernyőt vezetsz be.
