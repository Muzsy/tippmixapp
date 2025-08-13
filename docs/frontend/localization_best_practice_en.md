# 🌍 Localization Best Practices (EN)

This document summarizes the localization setup and best practices in TippmixApp.

---

## 📦 Setup

- Uses `flutter_localizations` and `intl` packages
- ARB files: `lib/l10n/app_hu.arb`, `app_en.arb`, `app_de.arb`
- Generated sources live in `lib/l10n` (`output-dir` in `l10n.yaml`, `synthetic-package: false`)
- Import via `package:tippmixapp/l10n/app_localizations.dart`

---

## 🧪 Access Pattern

```dart
context.loc.title
```

- Short extension method `loc()` wraps `AppLocalizations.of(context)!`
- Encouraged across all widgets
- All strings must come from ARB (no hardcoded labels)

---

## 🧠 Best Practices

- Always use `loc()` accessor
- Never use `.toString()` on localized content (risk of crash)
- Group strings by screen in ARB files for clarity
- Add `@flutter` metadata if needed for tool support
- Avoid duplicating the same string under multiple keys

---

## 🔀 Language Switching

- Supported via `LocaleProvider` and `SettingsService`
- Locale stored in `SharedPreferences`
- UI controlled by `MaterialApp.locale`
- Default fallback: `hu` (Hungarian)

---

## 🚧 Current Limitations

- No Settings UI to change language
- Some hardcoded strings remain
- German (`app_de.arb`) is incomplete and not tested
