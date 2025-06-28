## 🛠️ Navigációs hiba javítása – Hírfolyam képernyő nem jelenik meg

### 🎯 Funkció

A `router.dart` fájlban a `/feed` útvonal hibásan az `EventsScreen` komponenshez van rendelve. Ez azt eredményezi, hogy a hírfolyam menüpont vagy navigációs gomb hatására nem a közösségi aktivitásokat tartalmazó `FeedScreen` jelenik meg, hanem újra az eseménylista. A cél a `/feed` útvonal javítása.

### 🧠 Fejlesztési részletek

A jelenlegi hibás definíció:

```dart
GoRoute(
  path: '/feed',
  builder: (context, state) => const EventsScreen(sportKey: 'soccer'),
),
```

A módosított, helyes változat:

```dart
GoRoute(
  path: '/feed',
  name: AppRoute.feed.name,
  pageBuilder: (context, state) => CustomTransitionPage(
    child: const FeedScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  ),
),
```

Ez biztosítja, hogy a `FeedScreen` jelenjen meg, amely a valós idejű közösségi aktivitásokat tartalmazza (másolás, komment, jelentés, stb.).

### 🧪 Tesztállapot

A `FeedScreen` már tesztelt komponens (widget teszt létezik). Ennek ellenére javasolt tesztet írni arra, hogy a `/feed` route helyesen rendereli ezt a képernyőt.

### 🌍 Lokalizáció

A `FeedScreen` UI lokalizációs kulcsokat használ, melyek már bevezetésre kerültek (pl. `feed_event_*`). A javítás nem igényel új kulcsot.

### 📎 Kapcsolódások

* `router.dart` – útvonal-definíciók
* `feed_screen.dart` – a hírfolyam teljes képernyője
* `AppRoute.feed` enum – azonosító
* `FeedService`, `HomeFeedWidget` – feed adatforrás és komponensek

---

Ez a vászon kizárólag a `/feed` útvonal javítására koncentrál. További navigációs problémák külön vásznakban kerülnek rögzítésre.
