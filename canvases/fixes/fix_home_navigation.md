# Navigációs hiba – Home gomb & induláskor a Feed jelenik meg

## Kontextus

* Megfigyelt hiba\*: app indításakor **és** az alsó navigációs sáv *Home* gombjára kattintva nem a kezdőképernyő (**Home grid**), hanem a hírfolyam (**Feed**) jelenik meg.
* **Oknyomozás**

  1. `/` útvonal (`AppRoute.home`) → `NoTransitionPage(child: AuthGate())`.
  2. A `ShellRoute` *builder* a `HomeScreen`-t rendereli, a `child` paraméter pedig az **AuthGate** widget.
  3. A `HomeScreen._buildBody()` feltétel – ha root útvonal és `child != null && child is! SizedBox` – visszaadja a `child`‐et, tehát az AuthGate‐et.
  4. Az **AuthGate** sikeres authentikáció után `context.go('/feed')`‑re irányít, ezért a Feed képernyő ugrik fel.

> Röviden: a Home képernyő sosem kap lehetőséget megjelenni, mert az AuthGate rooton mindig továbbnavigál a Feedre.

## Megoldás

* **A `HomeScreen`‐ben** módosítjuk a feltételt, hogy az **AuthGate‐et üres placeholdernek** tekintse, így a Home grid jelenik meg. Ez egyetlen sor módosítás + 1 import.
* Az AuthGate kódját nem kell piszkálni, így továbbra is gondoskodik az anon felhasználók átirányításáról / email verifikációról.

## Feladatok

* [ ] `lib/screens/home_screen.dart` fájl:

  * Import: `import 'package:tippmixapp/ui/auth/auth_gate.dart';`
  * IF‐feltétel módosítása: `child is! SizedBox && child is! AuthGate`.
* [ ] `flutter analyze` hibamentes.
* [ ] Widget‑ és navigációs teszt: indításkor, ill. Home gombra kattintva `HomeScreen` grid jelenik meg, **nem** a Feed.

## Acceptance Criteria

* [ ] App indításakor (bejelentkezett & email‑valid user) a kezdőképernyő jelenik meg.
* [ ] BottomNav *Home* gombja mindig a kezdőképernyőre navigál.
* [ ] Feed továbbra is elérhető a Feed gombbal.

## Hivatkozások

* YAML recipe: `/codex/goals/fix_home_navigation.yaml`
