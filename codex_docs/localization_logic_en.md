version: "2025-07-29"
last\_updated\_by: docs-bot
depends\_on: \[codex\_context.yaml]

# 🌍 Localization Logic Guidelines

> **Purpose**
> Explain how TippmixApp implements runtime i18n (hu, en, de) and set non‑negotiable rules so Codex never breaks the language flow.

---

## Supported languages

| Code | Language  |
| ---- | --------- |
| `hu` | Hungarian |
| `en` | English   |
| `de` | German    |

All UI strings **must** be localized – no hard‑coded text is allowed.

---

## Directory & File Layout

```
lib/
 └─ l10n/
     ├─ app_hu.arb
     ├─ app_en.arb
     ├─ app_de.arb
     ├─ app_localizations.dart      # generated
     └─ *.g.dart                    # per‑language
l10n.yaml                            # Flutter gen config
```

*Every* new key is added to the 3 `.arb` files in the same commit.

---

## Access pattern

```dart
Text(loc(context).selectLanguage)
```

* `loc(BuildContext)` is a mandatory wrapper around `AppLocalizations.of(context)!`.
* Keys are strongly typed via the `AppLocalizationsKey` enum – **no** raw strings.

---

## Runtime language switch

| Component                                        | Responsibility                                                        |
| ------------------------------------------------ | --------------------------------------------------------------------- |
| `AppLocaleController` (`StateNotifier<Locale?>`) | Holds current locale and exposes `setLocale(String)` & `loadLocale()` |
| `appLocaleControllerProvider`                    | Riverpod provider read by the UI                                      |
| `SharedPreferences` (`selectedLanguage`)         | Persists the last chosen locale                                       |

```dart
MaterialApp.router(
  locale: ref.watch(appLocaleControllerProvider),
  supportedLocales: const [Locale('hu'), Locale('en'), Locale('de')],
  localizationsDelegates: AppLocalizations.localizationsDelegates,
)
```

Locale changes propagate instantly thanks to `notifyListeners()` in the controller.

---

## Testing requirements

1. Widget test asserts that each supported locale renders without throwing.
2. Golden tests run for all three languages on CI.
3. Failing to update an `.arb` file triggers the `l10n_gen` step and fails the pipeline.

---

## Codex hard rules

1. **Never** introduce hard‑coded strings – use an enum key.
2. **Do not** call `AppLocalizations.of(context)` directly – always use `loc()`.
3. Only extend existing `.arb` files when explicitly instructed via YAML goal.
4. A PR that adds a key **must** update hu/en/de translations together.

---

## Quick checklist

| ✅ Check                          | How to verify                                         |
| -------------------------------- | ----------------------------------------------------- |
| New key exists in 3 `.arb` files | `grep '"my_new_key"' lib/l10n/*.arb` = 3 hits         |
| Locale switch works              | Run app → change language in Settings – UI re‑renders |
| Tests pass for all locales       | `flutter test --tags=l10n`                            |

---

## Changelog

| Date       | Author   | Notes                                                                                    |
| ---------- | -------- | ---------------------------------------------------------------------------------------- |
| 2025-07-29 | docs-bot | Initial version extracted from `localization_logic.md` & `localization_best_practice.md` |
