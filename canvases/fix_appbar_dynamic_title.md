## 🛠️ Navigációs hiba javítása – AppBar cím dinamikus megjelenítése

### 🎯 Funkció

A `HomeScreen` AppBar címmezője (`title`) jelenleg statikus: minden képernyőn ugyanaz a felirat (pl. `loc.home_title`). Ez hibás viselkedés, mivel a `ShellRoute` alatti gyermekoldalak esetén is mindig ugyanaz jelenik meg.

Cél: dinamikus `AppBar.title` szöveg, amely az aktuális útvonal (route) alapján változik.

### 🧠 Fejlesztési részletek

A `HomeScreen` komponens rendelkezik `GoRouterState state` paraméterrel. Ennek segítségével az aktuális route alapján lehet címet megjeleníteni.

Például:

```dart
final currentPath = state.uri.path;
final titleText = switch (currentPath) {
  '/' => 'TippmixApp',
  '/feed' => loc.feed_title,
  '/profile' => loc.profile_title,
  '/my-tickets' => loc.my_tickets_title,
  '/badges' => loc.badges_title,
  '/rewards' => loc.rewards_title,
  '/notifications' => loc.notifications_title,
  '/settings' => loc.settings_title,
  _ => '',
};
```

Majd az AppBar-ban:

```dart
title: Text(titleText),
```

Ezzel a `HomeScreen` minden al-oldala a megfelelő lokalizált címet fogja mutatni.

### 🧪 Tesztállapot

Ajánlott widget teszt írása, amely route-navigációval ellenőrzi, hogy az AppBar cím megfelelő szöveget jelenít meg.

### 🌍 Lokalizáció

A címek lokalizált kulcsokon keresztül jelennek meg (pl. `feed_title`, `profile_title`, stb.). Ezek már a legtöbb esetben léteznek.

### 📎 Kapcsolódások

* `home_screen.dart` – AppBar konfiguráció
* `router.dart` – útvonalak azonosítása
* `AppRoute` enum – route nevek
* `AppLocalizations` – lokalizációs címkulcsok (pl. `loc.feed_title`)

---

Ez a vászon kizárólag a dinamikus címmegjelenítést dokumentálja a `HomeScreen` AppBar-jában.
