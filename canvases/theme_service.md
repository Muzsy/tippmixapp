# ThemeService (Riverpod Notifier)

---

🎯 **Funkció**

A ThemeService központi feladata a színséma és skin állapotának kezelése Riverpod (vagy Provider/bloc) alapú architektúrában. Ez biztosítja a skin-váltás, dark/light mód, illetve a jövőbeli dinamikus theme logika teljes körű, központi vezérlését. Minden widget csak ezen a service-en keresztül érheti el vagy változtathatja a theme állapotát.

---

🧠 **Fejlesztési részletek**

- Hozd létre a `lib/services/theme_service.dart` fájlt.
- Implementálj benne egy Riverpod Notifier (vagy StateNotifier/ChangeNotifier) osztályt, amely tartalmazza:
  - **schemeIndex** (jelenlegi skin indexe)
  - **isDark** (világos/sötét mód állapot)
  - Metódusok: `toggleTheme()`, `toggleDarkMode()`, `setScheme(index)`
- A state módosításakor minden változtatás notifikálja az érintett widgeteket.
- A state bővíthető: későbbi sprintekben hozzáadjuk a perzisztenciát (shared_prefs/Firestore).
- Csak a ThemeService módosíthatja központilag a theme állapotot, direkt setState tilos.
- Dokumentáció és komment minden metódushoz.

---

🧪 **Tesztállapot**

- Unit-tesztek: minden váltás helyesen működik (theme, skin, dark mode).
- State-rebuild teszt: widget rebuild csak akkor, ha ténylegesen változott a state.
- CI: legalább 90% coverage a theme_service.dart-ra.

---

🌍 **Lokalizáció**

- A theme állapot logika nem tartalmaz lokalizálandó mezőt.
- A skin nevek, leírások lokalizációja külön fájlban kezelhető.

---

📎 **Kapcsolódások**

- **ThemeBuilder**: minden theme-állapot változás után új ThemeData épül.
- **BrandColors**: a skin index függvényében a ThemeBuilder a megfelelő BrandColors presetet használja.
- **UI/Widgetek**: minden theme váltás, skin választás, dark/light mód csak ThemeService-n keresztül érhető el.
- **Későbbi sprintek**: perzisztencia (local/cloud), platformfüggő logika.

---
