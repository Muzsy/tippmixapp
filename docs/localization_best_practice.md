# Lokalizációs és Nyelvválasztási Rendszer – TippmixApp

Ez a dokumentum bemutatja a TippmixApp projektben alkalmazott teljes nyelvválasztási és lokalizációs rendszer működését, felépítését és integrációs szabályait. A cél, hogy Codex számára is értelmezhető, determinisztikus logikát biztosítsunk a lokalizációhoz kötődő bővítésekhez és fejlesztésekhez.

---

## 🌍 Támogatott nyelvek

- Magyar (`hu`)
- Angol (`en`)
- Német (`de`)

Az alkalmazás minden UI-szövege lokalizált, statikus szöveg nem maradhat a felület egyik részén sem.

---

## 🚀 Alaplogika

- Az alkalmazás első indításakor a **készülék rendszernyelvét** használja.
- Ha a user később másik nyelvet választ a drawerben, az **mentésre kerül**.
- A nyelvválasztás után a **teljes UI újrarenderelődik**, a kiválasztott nyelven.

---

## 🧠 Állapotkezelés

A nyelvi állapot `Riverpod` alapú, a következő komponensekkel:

- **Controller:** `AppLocaleController` (`StateNotifier<Locale?>`)
- **Provider:** `appLocaleControllerProvider`
- **Publikus metódusok:**
  - `loadLocale()` – betölti az elmentett vagy rendszer nyelvet
  - `setLocale(String code)` – beállítja és menti az új nyelvet

```dart
final appLocaleControllerProvider = StateNotifierProvider<AppLocaleController, Locale?>((ref) {
  return AppLocaleController();
});
```

---

## 💾 Perzisztencia – `language_utils.dart`

A kiválasztott nyelv `SharedPreferences` segítségével kerül mentésre.

- `saveSelectedLanguage(String code)` – mentés
- `getSavedLanguage()` – elmentett érték lekérdezése
- `getCurrentLanguage()` – platform nyelv lekérdezése + fallback ('en')

```dart
final prefs = await SharedPreferences.getInstance();
prefs.setString('selectedLanguage', code);
```

---

## 🏗️ `MaterialApp` konfiguráció

A `main.dart` vagy `app.dart` fájlban:

```dart
locale: ref.watch(appLocaleControllerProvider),
supportedLocales: [Locale('hu'), Locale('en'), Locale('de')],
localizationsDelegates: [...],
localeResolutionCallback: (locale, supported) =>
  supported.contains(Locale(locale?.languageCode ?? 'en'))
      ? Locale(locale!.languageCode!)
      : const Locale('en'),
```

---

## 🧭 Navigációs integráció (Drawer)

A drawer legalján található a „Nyelv választás” menüpont.

- Dialógust nyit (`AlertDialog`), ahol a három nyelv közül lehet választani
- A kiválasztott nyelv vizuálisan ki van emelve (`Icon(Icons.check)`)
- A `onLanguageChanged()` callback hívja a controller `setLocale()` metódusát

---

## 📦 Lokalizációs fájlok

- `lib/l10n/app_hu.arb`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_de.arb`

Fordítási kulcsok formája: `"select_language": "Nyelv választás"`, stb.

---

## ✅ Codex-integrációs szabályok

1. A nyelvválasztás mindig a `AppLocaleController` állapotán alapul.
2. Csak a `appLocaleControllerProvider` által visszaadott `Locale` használható a `MaterialApp` konfigurációban.
3. A lokalizációs fájlok mindig három nyelvet tartalmaznak, minden új kulcs mindhárom fájlba kerüljön.
4. Dialógus szövegek és opciók is lokalizáltak legyenek.
5. Ne használj `setState()`-t a nyelvváltáshoz, kizárólag globális Riverpod állapotkezelés engedélyezett.
6. A `lib/utils/language_utils.dart` mindig az elsődleges forrás a mentéshez.

---

## 🧪 Tesztelési elvárások

- Lokalizációs sanity teszt mindhárom nyelven
- Dialógusban helyes nyelvi kulcsok ellenőrzése
- Nyelvváltás után a főképernyőn is megfelelő nyelvű szövegek jelennek meg

---

Ez a dokumentum a Codex és fejlesztői csapat számára kötelező referenciaként szolgál a lokalizációs logika bővítésekor vagy módosításakor.

