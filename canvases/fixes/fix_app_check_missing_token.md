## ⚡️ Codex Canvas – "fix\_app\_check\_missing\_token"

### 🎯 Cél

- **Megszüntetni a regisztráció (és valójában az egész app) indulásakor bekövetkező *AssertionError*-t**, amely akkor dobódik, ha *debug* módban **nem** érkezik `--dart-define FIREBASE_APP_CHECK_DEBUG_TOKEN=…` compile‑time paraméter.
- A hibát a `lib/main.dart` 55–60. sorában lévő `assert` okozza.
- A futtatásnak nem szabad leállnia – elég, ha figyelmeztető logot írunk.

### 📝 Változtatások

```diff
@@
-  assert(
-    !kDebugMode || debugToken.isNotEmpty,
-    '⚠️  FIREBASE_APP_CHECK_DEBUG_TOKEN nincs megadva!\n'
-    'Adj meg --dart-define paramétert a build parancsban, '
-    'és állítsd be a környezeti változót a natív plugin számára (lásd launch.json).',
-  );
+  // Ne állítsuk le az appot, ha a compile‑time debug token hiányzik. A
+  // natív Firebase App Check plugint továbbra is elláthatjuk tokennel a
+  // `FIREBASE_APP_CHECK_DEBUG_TOKEN` környezeti változón keresztül.
+  if (kDebugMode && debugToken.isEmpty) {
+    debugPrint(
+      '⚠️  FIREBASE_APP_CHECK_DEBUG_TOKEN compile‑time value missing. '
+      'Folytatom futást – a natív réteg (env) még tartalmazhat tokent.',
+    );
+  }
```

ℹ️  **Sem a release buildet (kReleaseMode), sem a Play Integrity/App Attest provider választását nem érinti.** Csak debug módban, compile‑time token hiányakor lép életbe.

### ✅ Acceptance Criteria

1. **`flutter run` debug módban** ⟶ nincs *AssertionError*, az app elindul.
2. A logban megjelenik a figyelmeztető sor, ha a token nincs megadva compile‑time.
3. A `FirebaseAppCheck.instance.activate()` továbbra is debug providerrel fut.
4. **Bármely `flutter test`** lefut zölden (assert hiányában semmi sem bukik).

### 🧪 Teszt

- Manuális: `flutter clean && flutter run` *token nélkül* → app indul, regisztráció működik.
- Unit‑ / widget‑tesztek változatlanok, nem érinti őket.

### 📋 Teendők listája

| # | Feladat                             | Fájl            |
| - | ----------------------------------- | --------------- |
| 1 | `assert` blokk cseréje info‑logra   | `lib/main.dart` |
| 2 | `flutter test --coverage` futtatása |                 |

---

Hatás: a fejlesztői UX jelentősen javul – a token megadása továbbra is javasolt, de hiánya nem blokkolja a futást.
