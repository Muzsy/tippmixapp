version: "2025-07-29"
last\_updated\_by: docs-bot
depends\_on: \[codex\_context.yaml, theme\_rules\_en.md]

# 🎨 Téma- és Szabály Rendszer

> **Cél**
> Lefektetni a **FlexColorScheme** és a márkaszínek használatának meg nem alkuvó szabályait, hogy a Codex és az emberi fejlesztők egységes UI‑t készítsenek.

---

## Márkapaletta (seed színek)

| Token              | Hex       | Használat                           |
| ------------------ | --------- | ----------------------------------- |
| **BrandPrimary**   | `#008043` | Primary swatch alapszíne            |
| **BrandSecondary** | `#FF8C00` | Másodlagos / kiemelő                |
| **BrandNeutral**   | `#607D8B` | Felület, elválasztó, inaktív szöveg |
| **BrandDanger**    | `#E53935` | Hiba, destruktív művelet            |
| **BrandWarning**   | `#FFC107` | Figyelmeztetés, odds csökkenés      |
| **BrandSuccess**   | `#4CAF50` | Siker, odds növekedés               |

> *Ne* hard-code-old ezeket a hex értékeket widgetekben – mindig a `Theme.of(context).colorScheme.*` API-t használd.

---

## FlexColorScheme konfigurációs szabályok

1. **Seed mód** – `FlexThemeData.light()` / `FlexThemeData.dark()` hívása `primary = BrandPrimary` paraméterrel.
2. `surfaceMode` értéke legyen `SurfaceMode.highScaffoldLevelSurface`, hogy a Material 3 elevációval egyezzen.
3. `useMaterial3` **true** mindkét témánál.
4. `appBarStyle: FlexAppBarStyle.background`, így az AppBar a surface színt használja.
5. **Ne** írj felül manuálisan `textTheme`‑et – bízd a Tone mappingre.
6. Témafájlok kizárólag a `lib/src/theme/` mappában élhetnek (`app_theme.dart`, `theme_service.dart`).

---

## ThemeService feladatköre

| Metódus                                | Leírás                                                            |
| -------------------------------------- | ----------------------------------------------------------------- |
| `ThemeMode getThemeMode()`             | Visszaadja a `SharedPreferences`‑ben tárolt (`themeMode`) értéket |
| `Future<void> setThemeMode(ThemeMode)` | Elmenti az új módot és értesíti a hallgatókat                     |

A `themeModeProvider` (Riverpod) teszi elérhetővé az aktuális módot az UI számára.

---

## Komponens irányelvek

- Használd az `ElevatedButton` alapstílusát – **ne** készíts egyedi gradientes gombot.
- Padding/margin igazodjon a 8 dp-es gridhez (Material baseline).
- Ikonméretek: 24 dp, listákban sűrítve 20 dp.
- Dark téma esetén a szöveg kontrasztja érje el az **AA** szintet (>= 4.5). Ezt a CI‑ben a `flutter_a11y` lépés ellenőrzi.

---

## Gyors ellenőrző lista

| ✅ Ellenőrizd                          | Hogyan?                                            |
| ------------------------------------- | -------------------------------------------------- |
| Widget színei a `Theme.of`‑ból jönnek | Statikus analízis – nincs `Color(0xFF...)` literál |
| ThemeMode megmarad újraindítás után   | App fut → téma váltás → újraindítás → mód megmarad |
| CI accessibility pass                 | `flutter_a11y --min-contrast 4.5`                  |

---

## Változásnapló

| Dátum      | Szerző   | Megjegyzés                               |
| ---------- | -------- | ---------------------------------------- |
| 2025-07-29 | docs-bot | Első verzió több témafájl összevonásával |
