# HomeScreen `showGrid` helyes számítása

**Cél:** A `HomeScreen` komponens `showGrid` logikáját javítani úgy, hogy a `GoRouterState` új API-ját használja, és ne dobjon fordítási hibát.

## Háttér

A korábbi megoldás a `child is SizedBox` típusvizsgálaton alapult, ami nem volt megfelelő és a tesztek sem működnek vele.
A `GoRouter` 10.x+ verziókban eltávolították a `location` property-ket mind a `GoRouter`, mind a `GoRouterState` osztályból.

## Megoldási lépések

1. **ShellRoute módosítása** (ha még nem történt meg):

   ```dart
   ShellRoute(
     builder: (BuildContext context, GoRouterState state, Widget child) {
       return HomeScreen(child: child, state: state);
     },
     // …
   );
   ```
2. **HomeScreen konstruktor frissítése**:

   ```dart
   class HomeScreen extends ConsumerWidget {
     final Widget child;
     final GoRouterState state;
     const HomeScreen({ super.key, required this.child, required this.state });

     @override
     Widget build(BuildContext context, WidgetRef ref) {
       // …
     }
   }
   ```
3. **`showGrid` logika javítása** a `build` metódusban:

   ```diff
    @override
    Widget build(BuildContext context, WidgetRef ref) {
   -   final showGrid = child is SizedBox;
   +   final showGrid = state.uri.path == '/';

       return Column(
         children: [
           if (showGrid) const UserStatsHeader(),
           Expanded(child: child),
         ],
       );
    }
   ```

### Magyarázat

* A `state.uri.path` a jelenlegi útvonalrész (`'/'`, `'/profile'` stb.) összehasonlítására alkalmas.
* Alternatíva: `state.matchedLocation == '/'`, de a `uri.path` tisztább, ha csak az útvonalra vagyunk kíváncsiak.

Ezzel a javítással eltűnnek a fordítási hibák, és a tesztek is sikeresen lefutnak `initialLocation: '/'` beállítás mellett.
