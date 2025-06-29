## 🎯 Funkció

A navigáció jelenlegi működése során három súlyos hiba jelentkezik:

1. A gyökér (`/`) útvonal ahelyett, hogy a főképernyőt (HomeScreen) mutatná, továbbra is az EventsScreen-re van állítva.
2. Az AppBar címe nem változik dinamikusan az aktív képernyő szerint, hanem minden esetben statikus értéket mutat ("Főképernyő").
3. A `/feed` útvonal szintén hibásan az EventsScreen-t jeleníti meg, nem a FeedScreen-t.

Ezen hibák javítása kritikus a navigációs integritás és felhasználói élmény szempontjából.

## 🧠 Fejlesztési részletek

* A `router.dart` fájlban javítani kell a `GoRoute` definíciókat:

  * A `'/'` útvonal builder-ét `HomeMainScreen`-re kell állítani (pl. `builder: (context, state) => const HomeMainScreen(),`)
  * A `'/feed'` útvonal builder-ét `FeedScreen`-re kell cserélni.
* A `HomeScreen` widget AppBar címét dinamikussá kell tenni a `state.name` vagy `AppRoute` alapján:

  ```dart
  final routeName = state.name;
  final title = appBarTitles[routeName] ?? 'Tippmix';
  ```
* Az `appBarTitles` lehet egy `Map<String, String>` a különböző route-nevekhez rendelt címekkel.

## 🧪 Tesztállapot

* A `flutter test` során biztosítani kell, hogy:

  * A főképernyő (`/`) betöltéskor valóban `HomeMainScreen` legyen látható
  * A `FeedScreen` navigáció `context.goNamed(AppRoute.feed.name)` hívással működjön, és ne az EventsScreen jelenjen meg
  * Az AppBar címe helyesen frissül minden route-váltáskor

## 🌍 Lokalizáció

* Az AppBar címekhez használt `appBarTitles` kulcsai lokalizált változatban is elérhetők legyenek (`loc.homeTitle`, `loc.feedTitle`, stb.)

## 📎 Kapcsolódások

* `lib/router.dart` – route-definíciók
* `lib/screens/home_screen.dart` – ShellRoute parent képernyő
* `lib/screens/home_main_screen.dart` – valódi főtartalom
* `lib/screens/feed_screen.dart` – hírfolyam tartalom
* `lib/l10n/intl_*.arb` – lokalizált címek
* `test/router_test.dart` – route tesztelés

## ☑️ Ellenőrzési pontok

* [ ] `/` route = HomeMainScreen
* [ ] `/feed` route = FeedScreen
* [ ] AppBar címek dinamikusak
* [ ] Nincs többé EventsScreen sehol alapértelmezésben
