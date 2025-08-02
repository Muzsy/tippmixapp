## 🛠 fix_appcheck_debug_token

Ez a vászon az AppCheck debug token nem megfelelő kezeléséből adódó hibát dokumentálja.  A debug buildben az `AppCheck` token létrehozásakor a rendszer véletlenszerű unsafelist tokent generált, ami miatt a backend elutasította a kéréseket.  A fix során a debug tokent a `--dart-define` paraméterrel átadott értékre cseréltük, majd a `FirebaseAppCheck.instance.setToken(token, isDebug: true)` hívással állítottuk be【80843169424196†L0-L18】, biztosítva, hogy a debug környezetben is megfelelően működjön az AppCheck.
