# LoginRegisterScreen – Sprint 2: Social Login funkciók (háromnyelvű)

## 🎯 Funkció

A login/regisztrációs képernyő bővítése közösségi bejelentkezési lehetőségekkel (Google, Apple, Facebook) úgy, hogy azok teljes értékűen, modern UX/UI mellett, háromnyelvű felületen jelenjenek meg.

## 🧠 Fejlesztési részletek

* Középső blokkban, a meglévő emailes csempék mellett jelenjenek meg különálló social login csempék:

  * Google, Apple, Facebook bejelentkezés
  * Mindegyik csempe saját logóval, színkóddal, natív gomb- vagy csempe stílussal
* Social login flow: sikeres belépés, hibakezelés, visszalépés (cancel)
* Social loginból érkező adatok (pl. avatar, displayName, email) backend mentése (Firestore/User profile)
* Amennyiben a social profilhoz hiányzik a becenév vagy kép, kérje be a regisztráció végén (felhasználóbarát módon)
* Hibakezelés: minden hiba jól látható, háromnyelvű, felhasználóbarát üzenettel
* Tesztekhez, UI komponensekhez háromnyelvű támogatás minden szövegre

## 🧪 Tesztállapot

* Minden közösségi login flow UI tesztje (siker, hiba, visszalépés/cancel)
* Adatmentés tesztelése (user adat backendbe)
* Lokalizációs teszt: gombok, hibaüzenetek, minden flow háromnyelven

## 🌍 Lokalizáció

* Új social loginhoz kapcsolódó minden szöveg/felirat lokalizációs kulcsként, háromnyelvűen (HU/EN/DE)
* Teljes social login flow háromnyelvűen tesztelve

## 📎 Kapcsolódások

* login\_register\_screen.dart (UI, flow)
* auth\_service.dart (social auth implementáció)
* profile\_screen.dart (socialból bejövő adat megjelenítés)
* localization fájlok (új kulcsok, háromnyelvűen)
