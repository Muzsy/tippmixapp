# 🎨 TippmixApp Theme (Színséma) Kezelési Dokumentáció

---

## Áttekintés
A TippmixApp színséma rendszerének célja, hogy a teljes alkalmazás egységes, modern, hozzáférhető és karbantartható vizuális arculattal rendelkezzen – platformfüggetlenül, minden felhasználónak elérhetően. A theme kezelés alapja a Material 3 szabvány és a FlexColorScheme package.

---

## 1. **Alapelvek és architektúra**
- **Material 3 kompatibilitás**: A theme minden komponense a Flutter Material 3 szabványán alapul (useMaterial3: true), biztosítva a trendi, jövőálló megjelenést.
- **FlexColorScheme**: Minden színséma előre definiált vagy auditált FlexScheme-re épül, garantálva a dark/light mód, AA kontraszt és platformfüggetlenség teljes támogatását.
- **Widgetek színhasználata**: Kizárólag Theme.of(context).colorScheme vagy ThemeExtension alapján! Kézi hex, rgb vagy manuális színhasználat tilos.

---

## 2. **Skin-választék logika**
- Az app előre definiált, tesztelt skin-palettákat kínál a beállításokban (pl. zöld, pink, kék, lila, stb.).
- Felhasználó kizárólag ezekből választhat, minden skin dark/light módra auditált.
- Kiválasztott skin index/név a user profilhoz vagy local storage-hoz menthető, app indításkor automatikusan betöltődik.
- Skin-váltás azonnali, minden képernyőn él.

---

## 3. **ThemeService és állapotkezelés**
- A ThemeService felel a skin-váltás, mentés, visszatöltés teljes logikájáért.
- State management: ajánlott Riverpod/Provider/bloc.
- Minden skin-választás központilag itt történik, widgetek közvetlenül NEM férnek hozzá a theme állapotához.
- Példa: ThemeService.getTheme(), ThemeService.setTheme(index).

---

## 4. **Mentés és visszatöltés**
- Bejelentkezett user: skin index/név mentése Firestore user dokumentumba.
- Anonim vagy offline user: mentés shared_preferences vagy egyéb local storage-ban.
- App minden indításkor a legutóbbi választás alapján generálja a theme-et.

---

## 5. **Biztonság és minőségbiztosítás**
- Minden skin golden test (screenshot diff) és accessibility audit után kerülhet be.
- Linter (pl. avoid-hard-coded-colors) kötelező, hardcoded színhasználat pipeline-ban tiltott.
- Minden widget automatikusan a theme-ből kapja színét, semmilyen kézi beavatkozás nem engedélyezett.

---

## 6. **Bővíthetőség, kampány/brand skin logika**
- Új skin hozzáadásához csak az availableThemes listát kell bővíteni.
- Kampány, esemény, brand skin is felvehető – pipeline tesztelés után.
- Skin nevek, leírások, previewk minden platformon lokalizálhatók.

---

## 7. **Kódvázlat**
```dart
// availableThemes listához példa:
final List<FlexSchemeData> availableThemes = [
  FlexSchemeData(
    name: "Tippmix Zöld",
    scheme: FlexScheme.money,
    description: "Alap Tippmix színséma (zöld)",
  ),
  FlexSchemeData(
    name: "Pink Party",
    scheme: FlexScheme.pinkM3,
    description: "Lányos, vidám skin",
  ),
  // ... további skinek
];

// ThemeService használat példa:
ThemeData theme = FlexThemeData.light(
  scheme: availableThemes[selectedThemeIndex].scheme,
  useMaterial3: true,
);
ThemeData darkTheme = FlexThemeData.dark(
  scheme: availableThemes[selectedThemeIndex].scheme,
  useMaterial3: true,
);
```
---

## 8. **Tesztelés és CI integráció**
- Minden új skin automatikusan golden + accessibility pipeline-on átfut.
- Widget/integrációs tesztek: theme váltás, mentés/visszatöltés stabilitás.
- Linter szabály: minden manuális színhasználatot tilt.
- CI csak a sikeres pipeline után enged új skint produkcióba.

---

## 9. **Lokalizáció**
- Skin nevek, leírások és previewk minden platformon lokalizálhatók.
- Theme kezelés nem érinti a fordítási kulcsokat, de minden felhasználói szöveg lokalizálható.

---

## 10. **Kapcsolódó komponensek**
- Beállítások képernyő: skin-választó lista preview-val
- ThemeService: központi theme logika
- Firestore/local storage: skin mentés/visszatöltés
- Minden főképernyő: kizárólag theme-ből színez

---

**Ez a dokumentum a /docs könyvtárba helyezhető el, és a TippmixApp teljes theme/színséma kezelésének hivatalos leírása.**

