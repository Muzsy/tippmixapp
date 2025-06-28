## ➕ Fogadások hozzáadása a BottomNavigationBar-hoz

### 🎯 Funkció

A TippmixApp alsó navigációs sávjából (BottomNavigationBar) jelenleg hiányzik a "Fogadások" képernyő. A képernyő `/bets` útvonal alatt érhető el, de csak drawerből (oldalsó menüből) lehetne elérni. Cél, hogy közvetlen alsó navigációs ikonnal is elérhető legyen.

### 🧠 Fejlesztési részletek

A `app_navigation_bar.dart` fájl kezeli az alsó navigációt `NavigationBar` komponenssel.

#### 1. Új `NavigationDestination` hozzáadása

```dart
NavigationDestination(
  icon: const Icon(Icons.sports_soccer),
  label: loc.bets_title,
),
```

#### 2. onDestinationSelected kiegészítése

```dart
case 0: context.go('/'); break;
case 1: context.go('/feed'); break;
case 2: context.go('/bets'); break; // új
```

#### 3. selectedIndex logika frissítése

```dart
if (location.startsWith('/bets')) return 2;
```

### 🧪 Tesztállapot

Ajánlott widget teszt:

* bottom bar megnyomásával betöltődik-e a Fogadások képernyő
* `expect(find.text('Fogadások'), findsOneWidget)` ellenőrzés

### 🌍 Lokalizáció

* `loc.bets_title` kulcs már dokumentálva, új kulcs nem szükséges

### 📎 Kapcsolódások

* `app_navigation_bar.dart` – bottom bar logika
* `router.dart` – `/bets` route már létezik
* `home_screen.dart` – AppShell struktúra
* `AppLocalizations` – `bets_title` kulcs

---

Ez a vászon kizárólag a Fogadások képernyő alsó navigációs sávba illesztését dokumentálja.
