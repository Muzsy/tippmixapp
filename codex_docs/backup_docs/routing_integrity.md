# 🧭 routing\_integrity.md – TippmixApp-hoz igazított verzió

Ez a dokumentum a Codex számára előírt útválasztási (routing) integritási szabályokat tartalmazza. Célja, hogy minden képernyő elérhető legyen, minden route működjön, és minden útvonalon konzisztens legyen az argumentumkezelés. Az alkalmazás a `GoRouter` csomagot használja típusbiztos navigációval.

---

## 🎯 Funkció

- A navigáció deklaratív módon történik `GoRouter` segítségével
- Minden képernyő route-ként szerepel a `router.dart` fájlban
- A navigáció kizárólag `context.pushNamed()` vagy `context.goNamed()` hívással történhet
- Minden route egyedi névvel (`name:`) van regisztrálva

---

## 🧠 Fejlesztési részletek

### Route-definíciók

- A `router.dart` fájl tartalmazza az összes route-ot, névvel ellátva
- A route típus: `GoRoute`
- A fő router definíció: `final router = GoRouter(routes: [...])`
- A root route alatt `ShellRoute` is használva van, pl. BottomNavBar támogatására

### Navigációs hívások

```dart
context.pushNamed(AppRoute.settings.name); // helyes
context.goNamed(AppRoute.leaderboard.name); // helyes
```

- A `AppRoute` egy enum vagy class, amely a route neveket tartalmazza konzisztens módon
- Direkt string alapú hívások (pl. `context.go('/settings')`) tilosak

### Paraméteres route

- Ha paramétert is fogad (pl. userId):

```dart
GoRoute(
  name: 'userProfile',
  path: '/user/:id',
  builder: (context, state) {
    final id = state.pathParameters['id'];
    return UserProfileScreen(userId: id);
  },
)
```

- Navigáció:

```dart
context.goNamed('userProfile', pathParameters: {'id': userId});
```

---

## 🧪 Tesztállapot

- A Codex által generált minden új képernyőhöz ellenőrizni kell:

  - szerepel-e a `router.dart` fájlban megfelelő route-ként
  - rendelkezik-e `name:` értékkel
  - lehet-e rá navigálni tesztben (widget test: push → expect screen)
- A `flutter analyze` ellenőrzi, ha route hivatkozás hibás
- Widget teszt javasolt új képernyő navigációs útvonalának validálására

---

## 📎 Kapcsolódások

- `lib/router.dart` – főútvonal-regisztráció
- `lib/screens/**/*.dart` – képernyők, amik route célpontok
- `lib/controllers/navigation_controller.dart` – ha van központi nav wrapper
- `settings_screen.dart`, `leaderboard_screen.dart` – konkrét példák működő named route-ra

---

## 🔒 Codex-szabályok

1. Minden új képernyőnek **kötelező** route-ot regisztrálni `router.dart`-ban
2. Kizárólag `name:` alapú hivatkozás használható
3. Tilos direkt `context.go('/route')` vagy `Navigator.push()`
4. `pathParameters` csak akkor adható meg, ha a route `:param`-ot definiál
5. Ha új paraméteres route készül, `GoRoute` definícióját is hozzá kell adni
6. Route nevek centralizált enum/class struktúrában tárolandók (`AppRoute`)

---

Ez a dokumentum kötelező érvényű minden Codex által érintett képernyőnél, amely navigációt vagy útvonalat érint.
