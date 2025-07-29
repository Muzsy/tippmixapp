version: "2025-07-29"
last\_updated\_by: docs-bot
depends\_on: \[codex\_context.yaml]

# 🎨 Theme & Color Rules

> **Purpose**
> Provide non‑negotiable constraints for **FlexColorScheme** and brand colour usage so Codex and human developers generate visually consistent UI.

---

## Brand palette (seed colours)

| Token              | Hex       | Usage                           |
| ------------------ | --------- | ------------------------------- |
| **BrandPrimary**   | `#008043` | Seed colour for primary swatch  |
| **BrandSecondary** | `#FF8C00` | Secondary / Accent              |
| **BrandNeutral**   | `#607D8B` | Surface, divider, disabled text |
| **BrandDanger**    | `#E53935` | Error, destructive actions      |
| **BrandWarning**   | `#FFC107` | Warnings, odds down indicator   |
| **BrandSuccess**   | `#4CAF50` | Success, odds up indicator      |

> *Do not* hard‑code these hex values in widgets – access them via the `Theme.of(context).colorScheme.*` API.

---

## FlexColorScheme configuration rules

1. **Use seed mode** – call `FlexThemeData.light()` / `FlexThemeData.dark()` with `primary` = `BrandPrimary`.
2. `surfaceMode` must be `SurfaceMode.highScaffoldLevelSurface` to align with Material 3 elevations.
3. `useMaterial3` **true** for both light & dark themes.
4. Set `appBarStyle: FlexAppBarStyle.background` so the AppBar uses surface colour.
5. **Do not** override `textTheme` manually – rely on automatic Tone mapping.
6. Theme files live in `lib/src/theme/` only (`app_theme.dart`, `theme_service.dart`).

---

## ThemeService responsibilities

| Method                                 | Description                                               |
| -------------------------------------- | --------------------------------------------------------- |
| `ThemeMode getThemeMode()`             | Returns theme mode from `SharedPreferences` (`themeMode`) |
| `Future<void> setThemeMode(ThemeMode)` | Persists new mode and notifies listeners                  |

`themeModeProvider` (Riverpod) exposes the current mode to the UI.

---

## Component guidelines

* Use `ElevatedButton` default styles – **no** custom gradient buttons.
* Padding/margin must respect the 8‑dp grid (Material baseline).
* Icon sizes: 24 dp, 20 dp for dense lists.
* Dark theme must achieve **AA** contrast for body text (>= 4.5). Use `flutter_a11y` CI step.

---

## Quick checklist

| ✅ Check                             | How to verify                                     |
| ----------------------------------- | ------------------------------------------------- |
| Widget colours come from `Theme.of` | Static analysis – no `Color(0xFF...)` literals    |
| ThemeMode persists across restart   | Run app → change theme → relaunch → mode retained |
| CI passes accessibility step        | `flutter_a11y --min-contrast 4.5`                 |

---

## Changelog

| Date       | Author   | Notes                                                 |
| ---------- | -------- | ----------------------------------------------------- |
| 2025-07-29 | docs-bot | Initial version consolidated from multiple theme docs |
