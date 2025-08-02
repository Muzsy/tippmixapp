version: "2025-07-29"
last\_updated\_by: docs-bot
depends\_on: \[]

# 🧪 Testing Guidelines

> **Purpose**
> Define mandatory testing strategy for TippmixApp so Codex‑generated code meets quality gates and prevents regressions.

---

## 1. Test pyramid & responsibilities

| Layer                 | Maintainer            | What we test                                | Tools                                       |
| --------------------- | --------------------- | ------------------------------------------- | ------------------------------------------- |
| **Unit**              | Dev who owns the file | Pure logic, utils, repositories, services   | `flutter test`, `mocktail`, `riverpod_test` |
| **Widget**            | Feature owner         | Stateful widgets with basic interactions    | `flutter_test`, `WidgetTester`              |
| **Golden**            | Design & QA           | Pixel‑perfect rendering per screen & locale | `golden_toolkit`, `screen_matches_golden()` |
| **Integration / E2E** | QA automation         | Critical flows across screens & plugins     | `integration_test`, Firebase emulator       |

### Coverage target

- **Unit + widget tests combined ≥ 80 %** lines per package (enforced by CI).
- Golden and E2E tests are **additive**; they do not count toward coverage.

---

## 2. Folder & naming conventions

```
test/
  unit/
    <feature>/
      <file>_test.dart
  widget/
    <screen_name>_test.dart
  golden/
    <screen_name>_<locale>.png
  integration/
    <flow_name>_test.dart
```

- Use **snake\_case** for all test files.
- Golden baselines live under `test/golden/baseline/` and are checked into Git.

---

## 3. Mocking & fixtures

- **mocktail** for lightweight stubs; avoid Mockito.
- Provide fake implementations via **provider overrides** (Riverpod).
- JSON fixtures live in `test/fixtures/` and loaded with `FixtureReader` helper.

---

## 4. Continuous Integration steps (`.github/workflows/ci.yaml`)

1. `flutter pub get`
2. `flutter analyze --fatal-infos`
3. `flutter test --coverage`
4. `dart run coverage:format_coverage` → fail if < 80 %
5. `flutter_a11y --min-contrast 4.5`
6. `flutter test --tags=golden` (renders & compares)
7. `flutter drive --driver integration_test/driver.dart -d macos` (headless)

Any failure aborts the pipeline.

---

## 5. Accessibility & globalization

- Golden tests run for **hu/en/de** locales.
- `flutter_a11y` checks contrast & tappable target sizes.

---

## 6. Quick checklist before merging

| ✅ Check                | Command                                               |
| ---------------------- | ----------------------------------------------------- |
| Tests pass locally     | `flutter test --coverage`                             |
| Coverage ≥ 80 %        | `genhtml coverage/lcov.info --summary`                |
| New golden approved    | `golden_toolkit --update-goldens` after design review |
| Integration flow green | `flutter drive ...`                                   |

---

## Changelog

| Date       | Author   | Notes                           |
| ---------- | -------- | ------------------------------- |
| 2025-07-29 | docs-bot | Initial consolidated guidelines |
