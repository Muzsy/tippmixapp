## 📋 MyTickets képernyő navigációs javítása

Ez a dokumentum a `MyTicketsScreen` elérhetőségének hiányát javítja a TippmixApp alkalmazásban. A képernyő jelen van a projektben, de egyik fő navigációs útvonalból sem elérhető. A cél, hogy a képernyő az oldalsó menüből (Drawer) és az alsó navigációs sávból (BottomNavigationBar) is elérhető legyen.

---

### 🛠️ Szükséges módosítások

#### 1. 📂 Oldalsó menü (Drawer) bővítése

* Új `ListTile` hozzáadása:

```dart
ListTile(
  leading: const Icon(Icons.receipt_long),
  title: Text(AppLocalizations.of(context)!.myTickets),
  onTap: () {
    Navigator.pop(context);
    context.go(AppRoute.myTickets.path);
  },
)
```

* A szöveg lokalizált kulcsa: `myTickets`

#### 2. 🔽 Alsó navigációs sáv bővítése (BottomNavigationBar)

* Új `NavigationDestination` vagy `BottomNavigationBarItem`:

```dart
BottomNavigationBarItem(
  icon: Icon(Icons.receipt_long),
  label: AppLocalizations.of(context)!.myTickets,
)
```

* Index kezelés kiegészítése `MyTicketsScreen`-re mutató route-tal

#### 3. 🗺️ Route konfiguráció ellenőrzése (GoRouter)

* A következő útvonalnak jelen kell lennie:

```dart
GoRoute(
  path: '/my-tickets',
  name: AppRoute.myTickets.name,
  builder: (context, state) => const MyTicketsScreen(),
)
```

#### 4. 🌍 Lokalizáció (ARB fájl)

* app\_hu.arb:

```json
"myTickets": "Szelvényeim"
```

* app\_en.arb:

```json
"myTickets": "My Tickets"
```

* app\_de.arb:

```json
"myTickets": "Meine Scheine"
```

---

### 🧪 Tesztelés

* Nyisd meg az alkalmazást, és ellenőrizd:

  * A Drawer-ben megjelenik a „Szelvényeim” opció
  * Az alsó navigációs sávban szerepel az új ikon
  * Mindkét navigációs útvonal sikeresen megnyitja a `MyTicketsScreen`-t

---

### 📌 Összegzés

A MyTickets képernyő eddig nem volt bekötve egyik fő navigációs rendszerbe sem. A fenti módosításokkal ez a hiányosság megszűnik, és a felhasználó könnyedén elérheti szelvényeit mindkét fő navigációs komponensből.
