# Feed Navigation Test Failure Fix

**Probléma:** A `feed_navigation_test.dart` teszt futtatásakor az alábbi hiba jelentkezik:

```
Expected: exactly one matching candidate
Actual: Found 0 widgets with type "EventsScreen"
```

A teszt az `EventsScreen` típusú widget megjelenését várja, amikor a felhasználó a "Feed" menüpontra navigál alul található navigációs sávon vagy a drawer-en keresztül.

## Vizsgálat

1. A routes konfigurációban hiányzik (vagy hibásan szerepel) az a GoRoute/ShellRoute, mely a `Feed` (vagy `events`) útvonalat az `EventsScreen`-re mutatja.
2. A BottomNavigationBar item index -> route mapping nem tartalmazza a `Feed`-hez illeszkedő `EventsScreen` útvonalat.
3. A Drawer link sem navigál a helyes névre/id-re.

## Javítási lépések

1. **Új útvonal hozzáadása vagy meglévő korrigálása:**

   ```dart
   GoRoute(
     name: 'feed',
     path: '/feed',
     builder: (context, state) => const EventsScreen(),
   ),
   ```

   vagy ha ShellRoute alatt van:

   ```dart
   ShellRoute(
     builder: (context, state, child) => AppScaffold(child: child),
     routes: [
       GoRoute(
         name: 'feed',
         path: '/feed',
         pageBuilder: (context, state) => NoTransitionPage(child: const EventsScreen()),
       ),
       // … többi route …
     ],
   ),
   ```
2. **BottomNavigationBar mapping frissítése:** Győződj meg róla, hogy a `Feed` ikon és index megfelelően mutat a `'/feed'` útvonalra:

   ```dart
   BottomNavigationBar(
     currentIndex: _selectedIndex,
     onTap: (index) {
       final routeNames = ['home', 'feed', 'profile'];
       context.goNamed(routeNames[index]);
     },
     items: const [
       BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
       BottomNavigationBarItem(icon: Icon(Icons.rss_feed), label: 'Feed'),
       BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
     ],
   )
   ```
3. **Drawer navigációs elem:** Ellenőrizd, hogy a drawer list tile-ja a `context.go('/feed')` vagy `goNamed('feed')` hívást tartalmazza:

   ```dart
   ListTile(
     leading: const Icon(Icons.rss_feed),
     title: const Text('Feed'),
     onTap: () => context.goNamed('feed'),
   ),
   ```
4. **Tesztfrissítés (ha szükséges):** Győződj meg róla, hogy a teszt a `initialLocation: '/feed'` beállítást használja a megfelelő útvonalra való navigáció szimulálásához.

---

Ezekkel a lépésekkel a `navigate to Feed via bottom nav and drawer` teszt sikeresen megtalálja és megjeleníti az `EventsScreen` widgetet.
