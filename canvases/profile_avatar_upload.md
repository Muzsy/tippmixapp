# 🎯 Funkció

A felhasználó a profilképernyőn saját profilképét (avatarját) feltöltheti és módosíthatja. Sikeres feltöltés után az új kép mindenhol automatikusan megjelenik a fiókhoz tartozóan.

# 🧠 Fejlesztési részletek

* A jelenlegi avatar-feltöltés funkció nem működik, hibát dob ("Hiba történt az avatar beállításakor").
* Kép kiválasztása: galériából vagy kamerával (alapból galéria).
* Feltöltés: Firebase Storage-ba kerül az avatar, majd letöltési link frissül a Firestore user doksiban.
* Függőségek: `image_picker`, `firebase_storage`.
* Android/iOS permissionök beállítása szükséges (AndroidManifest.xml, Info.plist).
* Kód: `lib/screens/profile_screen.dart`, `lib/services/profile_service.dart`.
* A feltöltött képet a user Firestore rekordjában `avatarUrl` mezőbe kell írni, és a megjelenítő widgeteknek is ezt kell figyelniük.
* Hiba esetén informatív, lokalizált üzenet jelenjen meg.

# 🧪 Tesztállapot

* Manuális teszt: új avatar kiválasztás, feltöltés, lemondás, hiba szimulálása.
* Unit/widget tesztek: mock ImagePicker, mock Firebase Storage feltöltés/letöltés.
* Ellenőrizni kell: avatar megjelenése, cache törlés után is.

# 🌍 Lokalizáció

* Siker, hiba és visszajelző üzenetek legyenek minden használt nyelven (pl. "Avatar frissítve", "Hiba történt az avatar beállításakor").

# 📎 Kapcsolódások

* Érintett fájlok: `lib/screens/profile_screen.dart`, `lib/services/profile_service.dart`, avatar widgetek
* Firestore user rekord, avatarUrl mező
* Storage jogosultságok (Firebase Console)
* Mobil permissionök (Android/iOS)
