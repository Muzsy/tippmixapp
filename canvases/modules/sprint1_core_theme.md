# 🎨 Sprint1 – Core Theme

🎯 **Funkció**

Az alkalmazás egységes, testreszabható megjelenésének megteremtése `FlexColorScheme` és `ThemeBuilder` segítségével. A cél, hogy a világos és sötét témák következetes színsémát és tipográfiát használjanak, miközben lehetővé teszik az egyes képernyők egyedi stílusának meghatározását【160257798810002†L4-L18】.

🧠 **Felépítés**

- **ThemeBuilder & ThemeService**: a témák összeállítása és állapotkezelése.
- **FlexColorScheme**: alapjául szolgál a BrandColors osztály számára, amely definiálja az alapszíneket és az árnyalatokat.
- **BrandColors**: minden színkategóriát (primary, secondary, success, danger stb.) központi helyen meghatároz, így a további képernyők könnyen adaptálhatják.
- **Betűtípusok**: a témához kapcsolódó tipográfiát és méreteket szintén egységes komponens kezeli.

📄 **Kapcsolódó YAML fájlok**

- `fill_canvas_sprint1_core_theme.yaml` – összegyűjti a Codex számára a célokat és a részletes feladatlistát【160257798810002†L4-L18】.

🐞 **Fixek és tanulságok**

A vászon célja sablonként szolgálni, ezért fixeket itt nem tartalmaz. Fontos azonban, hogy a témák verziókövetése rendezett legyen, és a komponensek külön modulokban helyezkedjenek el.

🧪 **Tesztállapot**

A dokumentumban hangsúlyos követelmény, hogy a ThemeService és a kapcsolódó widgetek tesztjei magas, 90–100 %-os lefedettséggel rendelkezzenek【160257798810002†L4-L18】. Az egyes színkódok, brightness beállítások és betűtípusok módosítása esetén regressziós teszteket kell futtatni.

📎 **Modul hivatkozások**

- A témákat használó képernyők: [Home screen](../screens/home_screen.md), [Settings screen](../screens/settings_screen.md), [Login screen](../screens/login_screen.md).