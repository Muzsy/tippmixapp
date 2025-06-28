## 🛠️ Teszthiba javítása – UserStatsHeader nem jelenik meg a HomeScreen-en

### 🎯 Funkció

A `test/screens/home_screen_test.dart` fájl egyik tesztje szerint a `UserStatsHeader` widget nem jelenik meg a `HomeScreen` betöltésekor, holott a `showStats: true` beállítás megtörtént. A cél annak biztosítása, hogy a widget mindig megjelenjen, amikor a teszt ezt elvárja.

### 🧠 Fejlesztési részletek

A `HomeScreen` valószínűleg egy `showStats` nevű flag alapján dönti el, hogy megjelenítse-e a `UserStatsHeader` widgetet.

1. Ellenőrizzük, hogy a teszt valójában a következő paraméterrel hívja:

```dart
HomeScreen(state: state, child: const SizedBox.shrink(), showStats: true)
```

2. A `HomeScreen` build metódusában valószínű ilyen részlet található:

```dart
if (showStats) UserStatsHeader(...),
```

3. Ellenőrizzük, hogy a widget valóban része a `body`-nak és nem valamilyen `Visibility`, `FutureBuilder` vagy async provider miatt nem jelenik meg. Lehetséges, hogy a `UserStatsHeader` csak akkor látszik, ha van bejelenkezett user vagy `statsProvider` adat érkezik.

### ✅ Javasolt megoldás

* Tegyük függetlenné a `UserStatsHeader` renderelését a tesztkörnyezettől (pl. mock vagy fallback statisztika).
* Ellenőrizzük, hogy a widget provider dependency-jei be vannak állítva a teszt során.

### 🧪 Tesztállapot

A következő teszt hibás:

* `HomeScreen shows tiles based on providers`

  * `Expected: exactly one matching candidate; Actual: none found of type "UserStatsHeader"`

A javítás után a tesztnek át kell mennie.

### 🌍 Lokalizáció

A `UserStatsHeader` nem tartalmaz külön lokalizációs kulcsokat. Nem érintett.

### 📎 Kapcsolódások

* `home_screen.dart` – a widget megjelenésének feltétele
* `user_stats_header.dart` – maga a komponens
* `home_screen_test.dart` – teszt, amely ellenőrzi a jelenlétét
* Esetleges provider vagy `AuthService` függőség: `statsServiceProvider`, `authProvider`

---

Ez a vászon csak a `UserStatsHeader` tesztelési problémájára koncentrál.
