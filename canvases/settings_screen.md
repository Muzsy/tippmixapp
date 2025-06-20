## 🎯 Funkció

A `SettingsScreen` célja, hogy a felhasználók testreszabhassák az alkalmazás működését és megjelenését. Alapbeállításokat tartalmaz (téma, nyelv, kijelentkezés), de előkészített a jövőbeni funkciók fogadására, mint például AI-tippek kapcsolása, kedvenc sportágak megadása vagy értesítési preferenciák.

## 🧠 Fejlesztési részletek

* A képernyő szekció-alapú, külön komponensekre bontva: Téma, Nyelv, Fiók, Funkciókapcsolók.
* `SettingsSection` enum alapján modularizálható.
* Beállítható értékek (Sprint1):

  * Téma mód: `System`, `Light`, `Dark`
  * Nyelv: `hu`, `en`, `de` (AppLocalizations)
  * Kijelentkezés (FirebaseAuth.signOut())
* Előkészítés (de még nem működik):

  * Push toggle
  * AI-ajánlások kapcsoló (A/B teszt jelleggel)
  * Kedvenc sportágak (user preferencia modell)
* Állapotkezelés: ajánlott `SettingsController` / `Notifier` mintával dolgozni (pl. Riverpod vagy StateNotifier)

## 🧪 Tesztállapot

* Widget tesztek: minden szekció tesztelése (váltás, mentés, kijelentkezés)
* Lokalizációs váltás teszt: `AppLocalizations.load()` tesztálása
* Tartalmaz sanity-tesztet három nyelven való futtatásra

## 🌍 Lokalizáció

* Teljes UI a `AppLocalizations` enum-alapú rendszeréből dolgozik.
* Minden kulcs (pl. `settings_title`, `language_label`, `logout_button`) szerepel három nyelven.
* Dinamikus nyelvváltás `SettingsController` segítségével történik.

## 📎 Kapcsolódások

* `AppThemeController`, `AppLocaleController` – téma és nyelvváltás kezelése
* `FirebaseAuthService` – kijelentkezés
* `user_model.dart` – jövőbeni preferenciák mentése
* `AppLocalizations` – lokalizációs rendszer

## 📚 Input dokumentumok

* `docs/auth_best_practice.md`
* `docs/tippmix_app_teljes_adatmodell.md`
