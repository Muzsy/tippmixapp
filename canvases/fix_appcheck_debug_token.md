# Sprint0 – App Check debug token fix

## Kontextus

A jelenlegi debug buildben a `FirebaseAppCheck` **minden indításkor** új, nem safelist‑elt debug tokent generál, mert a `main.dart`‑ban ugyan `AndroidProvider.debug` / `AppleProvider.debug` ággal aktiváljuk, de **nem adunk át explicit tokent**. A Console ezért *“Debug token not allowed”* hibával blokkolja a backend‑hívásokat.

## Cél (Goal)

Stabil, kézzel megadott debug token használata, amelyet a Firebase Console‑ban előre regisztrálunk, így a debug build App Check‑je mindig érvényes – nincs több *invalid‑app‑check token* hiba.

## Feladatok

* [ ] Frissítsd a `firebase_app_check` csomagot ≥ 0.2.0‑ra (ha szükséges).
* [ ] Olvasd ki a `--dart-define=FIREBASE_APP_CHECK_DEBUG_TOKEN` paraméter értékét a `main.dart`‑ban.
* [ ] `FirebaseAppCheck.instance.activate()` után, **debug módban**, hívd meg
  `FirebaseAppCheck.instance.setToken(debugToken, isDebug: true)`  ha a token nem üres.
* [ ] Adj hozzá unit‑/widget‑tesztet mockolt `FirebaseAppCheck`‑kel, amely ellenőrzi, hogy debug módban nem generálódik új token.
* [ ] Dokumentáld a futtatási módot a README‑ben (pl. VS Code launch config példával).

## Acceptance Criteria / Done Definition

* [ ] `flutter analyze` hibamentes
* [ ] Minden új teszt zöld (≥ 80 % lefedettség érintett fájlokra)
* [ ] Debug build indításakor **nem** logol új App Check tokent
* [ ] A regisztrált debug tokennel a bejelentkezés és Firestore hívások sikeresen lefutnak

## Hivatkozások

* Canvas → `/codex/goals/fix_appcheck_debug_token.yaml`
* Firebase docs: *Enable App Check in debug mode* (referenciaként)
