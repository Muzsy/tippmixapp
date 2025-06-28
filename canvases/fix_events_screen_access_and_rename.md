## 🛠️ Navigációs hiba javítása – Események képernyő átnevezése és elérhetőségének biztosítása

### 🎯 Funkció

A `router.dart` fájlban szerepel egy `/events` útvonal, amely az `EventsScreen`-re mutat. Azonban jelenleg **sem a drawerben, sem az alsó navigációban nincs link vagy gomb**, amely elérhetővé tenné ezt a képernyőt. A képernyő logikai szerepe a sportesemények / odds listák megjelenítése – ezt mostantól **„Fogadások”** néven célszerű szerepeltetni.

### ✅ Javítási lépések

1. **Útvonal és route enum átnevezése**

   * `/events` → `/bets`
   * `AppRoute.events` → `AppRoute.bets`

2. **Képernyőnév módosítása**

   * `EventsScreen` → változatlan maradhat, de a UI-ban „Fogadások” néven jelenik meg
   * Lokalizációs kulcs: `loc.bets_title`

3. **Navigáció hozzáadása**

   * Az `AppDrawer`-be (vagy más UI elembe) egy új `ListTile` kerüljön:

```dart
ListTile(
  leading: const Icon(Icons.sports_soccer),
  title: Text(loc.bets_title),
  onTap: () {
    Navigator.pop(context);
    context.goNamed(AppRoute.bets.name);
  },
),
```

4. **AppBar dinamikus cím**

   * A `home_screen.dart`-ban a `state.uri.path` alapján történő címmegjelenítéshez adjuk hozzá:

```dart
'/bets' => loc.bets_title,
```

### 🧪 Tesztállapot

Javasolt widget-teszt:

* Drawer megnyitása → Fogadások menü kiválasztása → EventsScreen (Fogadások) megjelenése + drawer bezáródása

### 🌍 Lokalizáció

Új kulcs: `bets_title`

* app\_hu.arb: „Fogadások”
* app\_en.arb: „Bets”
* app\_de.arb: „Wetten”

### 📎 Kapcsolódások

* `router.dart` – útvonal átnevezés
* `AppDrawer` – új menüpont
* `AppRoute` – enum módosítás
* `AppLocalizations` – új kulcs
* `home_screen.dart` – AppBar dinamikus címfrissítés

---

Ez a vászon az EventsScreen használhatóságát állítja helyre, és átnevezi a képernyőt Fogadások-ra.
