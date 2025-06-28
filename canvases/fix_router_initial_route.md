## 🛠️ Navigációs hiba javítása – Kezdőképernyő nem a HomeScreen

### 🎯 Funkció

A `router.dart` fájlban jelenleg az `'/'` útvonal (az alkalmazás kezdőképernyője) hibásan az `EventsScreen` komponenshez van rendelve. Ez azt eredményezi, hogy az alkalmazás indulásakor nem a csempés főképernyő (`HomeScreen`) jelenik meg, hanem az eseménylista. A javítás célja, hogy az `'/'` útvonal valóban a `HomeScreen`-t töltse be, annak tartalmával együtt.

### 🧠 Fejlesztési részletek

A `router.dart` fájl jelenlegi szakasza:

```dart
GoRoute(
  path: '/',
  name: AppRoute.home.name,
  builder: (context, state) => const EventsScreen(sportKey: 'soccer'),
),
```

Ez lecserélendő a következőre:

```dart
GoRoute(
  path: '/',
  name: AppRoute.home.name,
  builder: (context, state) => HomeScreen(state: state, child: const SizedBox.shrink(), showStats: true),
),
```

Ez a változtatás biztosítja, hogy a `ShellRoute` által körülölelt `HomeScreen` komponens valóban érvényes megjelenítést kapjon, és a widgetek (pl. statisztikai header, bónusz csempe stb.) megjelenjenek.

### 🧪 Tesztállapot

Nincs külön teszt a kezdőútvonal viselkedésére. Javasolt legalább egy widget teszt írása, amely ellenőrzi, hogy a főképernyőn megjelenik pl. a `UserStatsHeader`.

### 🌍 Lokalizáció

A változás nem érint lokalizációs kulcsokat, de a `HomeScreen` alatt lévő csempék lokalizált szövegei így végre érvényesülnek.

### 📎 Kapcsolódások

* `router.dart` – útvonal-definíciók
* `home_screen.dart` – a valódi főképernyő tartalma
* `AppRoute.home` enum – route azonosító
* `UserStatsHeader`, `HomeTile*` – HomeScreen tartalmak

---

Ez a vászon kizárólag az elsődleges útvonal (`'/'`) javítására koncentrál. További navigációs problémák külön vásznakban kerülnek dokumentálásra.
