# 🎨 Theme Rules & Styling (EN)

This document defines the theming rules and design tokens in TippmixApp.

---

## 🎯 Design Goals

- Use Material 3 and FlexColorScheme
- Consistent dark/light themes
- Easily overridable color palette

---

## 🎨 Technologies

- `flex_color_scheme` package (M3-based)
- `ThemeService` manages mode switching
- Theme definitions in centralized config

---

## 🌈 Colors

- Defined via `BrandColors` class
- Stored in `lib/constants/colors.dart`
- Example:

```dart
class BrandColors {
  static const Color primary = Color(0xFF016D3D);
  static const Color secondary = Color(0xFF49B67D);
  static const Color accent = Color(0xFFE4F3EC);
}
```

---

## 🧠 Best Practices

- Do not hardcode colors in widgets
- Use `Theme.of(context).colorScheme.*`
- Prefer `ThemeService` for switching theme mode
- Avoid overriding the global theme in nested widgets
- Use semantic color naming (primary, error, surface)

---

## 🧪 Testing Requirements

- Golden tests required for dark/light themes
- Accessibility contrast check recommended
