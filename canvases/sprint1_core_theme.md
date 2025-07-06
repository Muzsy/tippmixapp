# Sprint1 – Core Theme Architecture

🎯 **Funkció**  
A Sprint1 célja a TippmixApp színséma-rendszerének alapvető, jövőálló architektúrájának kiépítése. Megvalósul a FlexColorScheme-alapú ThemeBuilder, a Tippmix-specifikus BrandColors ThemeExtension, és a központi ThemeService állapotkezelés. A fő alkalmazás (main.dart) már az új theme-architektúrát használja, de a meglévő UI-komponensek refaktorálása csak a következő sprintben (Sprint2) kezdődik.

---

🧠 **Fejlesztési részletek**

| Feladat                    | Állapot | Részletek                                                                                       |
|----------------------------|---------|-------------------------------------------------------------------------------------------------|
| T1.1 Pubspec & deps upgrade | ⏳      | flex_color_scheme, dynamic_color csomagok hozzáadása, `flutter pub get`, CI lockfile mentése     |
| T1.2 ThemeBuilder          | ⏳      | Új `/lib/theme/theme_builder.dart` fájl, `buildTheme()` (FlexThemeData.light/dark, useMaterial3) |
| T1.3 BrandColors extension | ⏳      | ThemeExtension: min. 2 Tippmix-szín (pl. BetSlipGradientStart/End)                              |
| T1.4 ThemeService          | ⏳      | Riverpod Notifier: currentSchemeIndex, isDark, toggleTheme, toggleDarkMode, setScheme           |
| T1.5 main.dart migráció    | ⏳      | Régi ThemeData hivatkozások cseréje ThemeBuilder-re, ThemeService provider bekötése              |
| T1.6 AppColors deprecate   | ⏳      | /legacy alá helyezés, @Deprecated annotáció, minden import eltávolítása                          |
| T1.7 Unit-tesztek          | ⏳      | Új és frissített tesztek: ThemeBuilder, ThemeService működés, min. 90% teszt coverage            |
| T1.8 Canvas + YAML         | ⏳      | sprint1_core_theme.md + fill_canvas_sprint1_core_theme.yaml elkészítése, Codex-kompatibilis módon|

---

🧪 **Tesztállapot**  
- CI pipeline: minden lépés (pubspec frissítés, tesztek, linter) zöld
- Unit tesztek: ThemeBuilder és ThemeService működésének automatikus tesztelése
- Code coverage: legalább 90%
- Minden régi AppColors referencia megszűnt, új Theme rendszer működik

---

🌍 **Lokalizáció**  
- A ThemeService által kezelt skin-nevek, leírások és preview-k minden platformon lokalizálhatóak
- Dokumentáció és Codex canvas magyar nyelvű
- Theme váltás, skin-nevek lokalizációja a következő sprintekben bővül

---

📎 **Kapcsolódások**  
- **Előzmény:** Sprint0 (color audit, baseline)
- **Következő:** Sprint2 (Widget Refactor – hex-színek teljes eltávolítása)
- BrandColors extension közvetlenül kapcsolódik a Tippmix színséma arculatához
- ThemeService architektúra a későbbi perzisztencia (Sprint3) és CI integráció (Sprint4-5) alapja

---

## **Összegzés**

A Sprint1 sikeres lezárásával a TippmixApp rendelkezik egy modern, skálázható, FlexColorScheme-alapú theme-architektúrával, amely készen áll a teljes UI refaktorra és a dinamikus skin-váltásra.

