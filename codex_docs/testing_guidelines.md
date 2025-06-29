# 📚 TippmixApp – Testing Guidelines (Codex‑ready)

> **Scope**: These rules govern every automated test generated or maintained by Codex for the TippmixApp project – unit, widget, golden, and integration. Apply them unless a task‑specific canvas overrides a detail.

---

## 1. Directory & Naming Conventions

* **Test files** live under `test/…` mirroring the `lib/…` structure.

  * `lib/services/auth_service.dart` → `test/services/auth_service_test.dart`
  * `lib/screens/profile_screen.dart` → `test/screens/profile_screen_test.dart`
* File names end with `_test.dart`; group names follow the Dart identifier of the class or widget.
* Keep ≤ 1 public class or widget under test per test file to reduce fixture coupling.

## 2. Supported Test Types

| Type            | Purpose                                                   | Package(s)                          |
| --------------- | --------------------------------------------------------- | ----------------------------------- |
| **Unit**        | Pure Dart logic – services, utils, providers (no Widgets) | `package:test`, `mocktail`, `clock` |
| **Widget**      | UI behaviour in isolation – screens, components           | `flutter_test`, `riverpod_test`     |
| **Golden**      | Pixel‑perfect UI snapshots (opt‑in)                       | `golden_toolkit`                    |
| **Integration** | End‑to‑end flows (rare, CI‑heavy)                         | `integration_test`                  |

> **Codex default**: generate **Unit** for `lib/services/**`, **Widget** for `lib/screens/**`.

## 3. Runtime Environment

* In **Codex** sandboxes call `dart run test` (❌ no `flutter test`).
* Locally devs may still run `flutter test`; ensure no Flutter‑only APIs leak into pure‑Dart suites.
* Disable network: set `Environment().allowNetwork = false` or mock HTTP.

## 4. Arrange‑Act‑Assert Template

```dart
void main() {
  group('AuthService', () {
    late AuthService service;
    setUp(() {
      service = AuthService(httpClient: mockClient, storage: fakeStorage);
    });

    test('returns tokens on 200', () async {
      // Arrange – mock HTTP 200
      when(() => mockClient.post(any(), body: any(named: 'body'))) // …
          .thenAnswer((_) async => Response(tokenJson, 200));

      // Act
      final result = await service.login('a@b.com', '1234');

      // Assert
      expect(result, isA<AuthTokens>());
    });
  });
}
```

* Use `group()` to cluster related cases; keep test names descriptive, english, lowercase (e.g. *"returns tokens on 200"*).
* Prefer **mocktail**; avoid Mockito’s code gen.
* Avoid `Future.delayed` in tests – use `clock` package or `fake_async`.

## 5. Provider & Dependency Injection

* Widgets tested inside a `ProviderScope`.
* Override production providers with **fakes/stubs** via `overrideWith` or `overrideWithProvider`.
* Never touch global singletons in tests – inject via constructor.

## 6. Mocking / Fake Libraries

| Concern        | Package                         | Pattern                             |
| -------------- | ------------------------------- | ----------------------------------- |
| HTTP           | `http/testing.dart`, `mocktail` | Return `Response` objects.          |
| Secure storage | `mocktail` fake class           | In‑memory `Map<String,String>`      |
| Firebase Auth  | `firebase_auth_mocks`           | Only if integration unavoidable     |
| Time           | `package:clock`                 | `withClock(Clock.fixed(...)) { … }` |
| Images/network | `NetworkAssetBundle` override   | supply local bytes                  |

## 7. Localization

* All **Widget tests** must wrap the widget in a MaterialApp with **three locales**:
  `Locale('en')`, `Locale('hu')`, `Locale('de')`.
* Verify that text widgets render with the active locale if business logic depends on localization.
* Use `WidgetsApp.textDirection` override for LTR/RTL where applicable.

## 8. Cache & Retry Testing (services)

* Provide a **FakeCache** implementing the `Cache` interface – reset between tests.
* Simulate retry sequences: first N attempts throw `SocketException` or 5xx, last attempt returns success.
* For **rate‑limit** tests mock HTTP 429 with `Retry‑After` header and advance fake clock.

## 9. Coverage & DoD

* **Unit tests** ≥ 85 % line coverage for the target file.
* **Widget tests** must cover at least one success and one error/empty state.
* CI must finish tests < 60 s overall.

## 10. Golden Files

* Prefix golden images `goldens/`.
* Store reference images in repo; update intentionally with `--update-goldens` flag.

## 11. YAML Goal Conventions

* Each goal file lives in `codex/goals/` and references exactly one **canvas**.
* The *inputs* list must include every library file under test **plus** any Codex docs required.
* The *steps* array should contain one declarative description – human readable, imperative present tense.

## 12. Forbidden Patterns

❌ `print()` statements in production code under test.
❌ Real network calls.
❌ `sleep` / `Future.delayed` in tests.
❌ Shared mutable state between tests without tearDown.

## 13. Useful Snippets

### 13.1 Fake Secure Storage

```dart
class FakeSecureStorage extends Fake implements SecureStorage {
  Map<String, String> _store = {};
  @override Future<void> write({required String key, required String value}) async => _store[key] = value;
  @override Future<String?> read({required String key}) async => _store[key];
  @override Future<void> delete({required String key}) async => _store.remove(key);
}
```

### 13.2 Fake Memory Cache

```dart
class FakeMemoryCache<T> implements Cache<T> {
  final _map = <String, CacheEntry<T>>{};
  @override T? get(String k) => _map[k]?.value;
  @override void set(String k, T v, Duration ttl) => _map[k] = CacheEntry(v, ttl);
  @override void invalidate(String k) => _map.remove(k);
}
```

---

### ✅ Maintain & Evolve

Keep this document version‑controlled; amend it alongside Sprint retros if new patterns emerge.
