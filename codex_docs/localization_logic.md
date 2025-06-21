# 🌍 localization\_logic.md – TippmixApp-hoz igazított verzió

Ez a dokumentum szabályrendszerként szolgál a Codex felé a TippmixApp lokalizációs rendszerének működéséhez. A cél egy szigorún enum-alapú, ARB-fájlokra épített lokalizációs struktúra, ahol a Codex csak és kizárólag a megengedett logikák mentén működik.

---

## 🎯 Funkció

* Az alkalmazás többnyelvű (hu, en, de) működést támogat
* A nyelvváltás valósidejű (runtime), nem igényel restartot
* Minden szöveg lokalizált és csak az `AppLocalizations` struktúrán keresztül érhető el
* A SettingsScreen-ből választható a nyelv

---

## 🧠 Fejlesztési logika

### Fő elemek:

* `lib/l10n/` tartalmazza:

  * `app_hu.arb`, `app_en.arb`, `app_de.arb`
  * `app_localizations.dart` + per-nyelv Dart generált fájlok
* `l10n.yaml` konfigurálja az l10n generálást
* A kulcsokat kizárólag enum reprezentálja: `AppLocalizationsKey`

### Lokalizált szöveg elérése:

```dart
loc(context).my_key // ahelyett, hogy AppLocalizations.of(context) kézileg lenne használva
```

A `loc` függvény egy shortcut wrapper, amit mindig használni kell.

### Nyelvváltás kezelése:

* `AppLocaleController` állítja a nyelvet
* A beállított locale a `shared_preferences`-ben tárolódik
* A `MaterialApp.router` konstruktor `locale:` paramétere az aktuális nyelv
* A beállítás valós időben frissüli (notifyListeners)

---

## 🧪 Tesztelhetőség

* `settings_screen_localization_test.dart` validálja, hogy minden toggle, menü és prompt lokalizálva van
* `flutter gen-l10n` futtatása CI pipeline-ban biztosítja a valid szinkront
* Lokalizációs sanity test lefuttatandó: `hu`, `en`, `de` nyelven

---

## 📎 Kapcsolódások

* `lib/controllers/app_locale_controller.dart` – nyelvváltás logika
* `settings_screen.dart` – nyelvválasztás UI
* `lib/l10n/` – ARB struktúra és generált fájlok
* `codex/goals/fill_canvas_settings_screen.yaml` – Codex-feladat definíció

---

## 🔒 Codex-szabályok

1. Codex csak akkor módosíthat szöveget, ha `AppLocalizationsKey` enum tartalmazza
2. Ne hozzon létre hardcoded szöveget
3. Ne használja közvetlenül az `AppLocalizations.of(context)` kézileg
4. Ne hozzon létre .arb fájlt, csak bővítse azt, ha explicit YAML-ban utasítjuk

---

Ez a dokumentum kötelező referencia a Codex számára bármely nyelvi vagy lokalizációs logikával kapcsolatos művelethez.
