# Sprint0 – App Check launch konfiguráció & felesleges kód eltávolítása

## Kontextus

A `FirebaseAppCheck` debug‑módja továbbra is új, nem safelist‑elt tokent generál, mert a build parancs **nem** ad át `FIREBASE_APP_CHECK_DEBUG_TOKEN` definíciót. A 0.3.x‑es plugin már *magától* felismeri ezt a környezeti változót, így a korábban beillesztett `setToken()` hívás feleslegessé vált. Ha a token üres, a könyvtár új kulcsot ír ki a logba, ami ismét hibát okoz.

## Cél (Goal)

*Debug build* esetén mindig a konzolban safelist‑elt debug‑tokennel fusson az alkalmazás, és ne legyen szükségtelen extra kód.

## Feladatok

* [ ] Hozz létre egy **`.vscode/launch.json`** konfigurációt, amely `--dart-define=FIREBASE_APP_CHECK_DEBUG_TOKEN=<TOKEN>` paraméterrel indítja a debug futtatást.
* [ ] A `lib/main.dart`‑ban:

  * [ ] Adj hozzá `assert(!kDebugMode || debugToken.isNotEmpty, ...)` sort a `debugToken` definiálása után.
  * [ ] Távolítsd el a `FirebaseAppCheck.instance.setToken(...)` blokkot (már nem szükséges).
* [ ] (Opcionális) Töröld a **`lib/firebase_app_check_ext.dart`** fájlt, ha a projektben van.
* [ ] Futtasd le a `flutter analyze --fatal-infos` parancsot – nincs új issue.

## Acceptance Criteria / Done Definition

* [ ] A debug‑build logja **nem** ír ki új „Enter this debug secret…” sort.
* [ ] Az app sikeresen kommunikál a backenddel debug‑módban.
* [ ] `flutter analyze` hibamentes.

## Hivatkozások

* Canvas → `/codex/goals/fix_appcheck_launch.yaml`
* Firebase docs: *Enable App Check in debug mode* (0.3.x plugin behaviour)
