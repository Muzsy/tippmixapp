# 🌍 Lokalizációs legjobb gyakorlatok (HU)

Ez a dokumentum bemutatja a TippmixApp lokalizációs beállításait és ajánlott használatát.

---

## 📦 Alapbeállítások

- `flutter_localizations` + `intl` csomag használat
- ARB fájlok: `lib/l10n/app_hu.arb`, `app_en.arb`, `app_de.arb`
- Generált osztály: `AppLocalizations`

---

## 🧪 Használati minta

```dart
context.loc.title
```

- `loc()` extension metódus: `AppLocalizations.of(context)!` rövidítése
- Minden widgetben ajánlott így hivatkozni
- Minden szöveg ARB fájlból származzon (ne legyen hardcoded)

---

## 🧠 Ajánlások

- Használj mindig `loc()`-ot
- Ne alkalmazz `.toString()`-et lokalizált objektumon – hibát okozhat
- Csoportosítsd a kulcsokat képernyőnként az ARB fájlokban
- Adj meg `@flutter` metaadatot ha szükséges
- Ne ismételd ugyanazt a szöveget több kulcs alatt

---

## 🔀 Nyelvváltás

- `LocaleProvider` + `SettingsService` kezeli
- Beállítás `SharedPreferences`-ben tárolódik
- A UI a `MaterialApp.locale` alapján vált nyelvet
- Alapértelmezett fallback: magyar

---

## 🚧 Jelenlegi hiányosságok

- Nincs Beállítások képernyő nyelvváltáshoz
- Néhány szöveg még be van égetve
- Német (`app_de.arb`) fordítás hiányos, nem tesztelt
