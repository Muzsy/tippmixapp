version: "2025-08-13"
last\_updated\_by: codex-bot
depends\_on: \[codex\_context.yaml, localization\_logic\_en.md]

# 🌍 Lokalizációs logika irányelvei

> **Cél**
> Bemutatja, hogyan valósítja meg a TippmixApp a futásidejű i18n-t (hu, en, de), és rögzíti azokat a szabályokat, amelyek garantálják, hogy a Codex ne törje meg a nyelvi folyamatot.

---

## Támogatott nyelvek

| Kód  | Nyelv  |
| ---- | ------ |
| `hu` | Magyar |
| `en` | Angol  |
| `de` | Német  |

Minden UI‑szövegnek **lokalizáltnak** kell lennie – hard‑coded szöveg nem maradhat.

---

## Könyvtár- és fájlstruktúra

```
lib/
 └─ l10n/
     ├─ app_hu.arb
     ├─ app_en.arb
     ├─ app_de.arb
     ├─ app_localizations.dart      # generált
     └─ *.g.dart                    # nyelvspecifikus
l10n.yaml                            # Flutter gen konfiguráció
```

*Bármilyen* új kulcsot a 3 `.arb` fájlba **ugyanabban a commitban** kell felvenni.
Az `l10n.yaml` gyökérfájlban `output-dir: lib/l10n` és `synthetic-package: false` beállításokkal a generált források a repóban
élnek, és `package:tippmixapp/l10n/app_localizations.dart` útvonalon importálhatók.

---

## Szöveg elérése

```dart
Text(loc(context).selectLanguage)
```

- A `loc(BuildContext)` wrapper kötelező, az `AppLocalizations.of(context)!` hívást helyettesíti.
- A kulcsokat az `AppLocalizationsKey` enum típusosan kezeli – **nyers string nem megengedett**.

---

## Futásidejű nyelvváltás

| Komponens                                        | Felelősség                                                               |
| ------------------------------------------------ | ------------------------------------------------------------------------ |
| `AppLocaleController` (`StateNotifier<Locale?>`) | Aktuális locale tárolása, `setLocale(String)` & `loadLocale()` metódusok |
| `appLocaleControllerProvider`                    | Riverpod provider, amelyet az UI figyel                                  |
| `SharedPreferences` (`selectedLanguage`)         | A legutóbb választott nyelv perzisztálása                                |

```dart
MaterialApp.router(
  locale: ref.watch(appLocaleControllerProvider),
  supportedLocales: const [Locale('hu'), Locale('en'), Locale('de')],
  localizationsDelegates: AppLocalizations.localizationsDelegates,
)
```

A nyelvváltás azonnal érvényesül a `notifyListeners()` hívás miatt.

---

## Tesztkövetelmények

1. Widget‑teszt minden támogatott nyelvre, hogy hiba nélkül renderel.
2. Golden‑tesztek mindhárom nyelvre a CI-ben.
3. Ha egy `.arb` fájl frissítése elmarad, a `l10n_gen` lépés hibával leáll.

---

## Codex szigorú szabályai

1. **Soha** ne kerüljön hard‑coded string – használj enum kulcsot.
2. **Ne** hívd közvetlenül az `AppLocalizations.of(context)` metódust – mindig a `loc()`-ot használd.
3. `.arb` fájlokat csak akkor módosíts, ha YAML‑goal kifejezetten kéri.
4. Új kulcs hozzáadásakor **mindhárom** nyelvi fájl frissüljön.

---

## Gyors ellenőrző lista

| ✅ Ellenőrizd              | Hogyan?                                            |
| ------------------------- | -------------------------------------------------- |
| Új kulcs 3 `.arb` fájlban | `grep '"my_new_key"' lib/l10n/*.arb` = 3 találat   |
| Nyelvváltás működik       | App fut → Settings > nyelvváltás – UI újrarenderel |
| Tesztek lefutnak          | `flutter test --tags=l10n`                         |

---

## Változásnapló

| Dátum      | Szerző   | Megjegyzés                                                                      |
| ---------- | -------- | ------------------------------------------------------------------------------- |
| 2025-07-29 | docs-bot | Első verzió a `localization_logic.md` & `localization_best_practice.md` alapján |
