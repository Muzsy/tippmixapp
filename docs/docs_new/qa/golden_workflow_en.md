# 🧪 Golden Testing & Accessibility (EN)

This document outlines the visual testing (golden tests) and accessibility (a11y) workflow in TippmixApp.

---

## 🖼️ Golden Testing

Golden tests capture widget screenshots and compare them with a reference.

### Tooling

* Uses `flutter_test` and `matchesGoldenFile()`
* Test files in `test/golden/`
* Reference images stored under `test/golden/_goldens/`

### Workflow

1. Create a widget test
2. Render the widget with fixed dimensions
3. Compare with golden image

```dart
testWidgets('ProfileHeader golden test', (tester) async {
  await tester.pumpWidget(MyApp());
  await expectLater(
    find.byType(ProfileHeader),
    matchesGoldenFile('goldens/profile_header.png'),
  );
});
```

### Rules

* Test both light and dark mode
* Separate files: `*_light.png`, `*_dark.png`
* Avoid dynamic content (e.g. timestamps)

---

## ♿ Accessibility Checks

TippmixApp aims for basic a11y compliance:

* Uses `Semantics()` for important elements
* Ensures `Text()` widgets have sufficient contrast
* Custom widgets (e.g. buttons, icons) should have tooltips or semantic labels

### Tools

* `flutter_test` supports basic semantics testing
* Golden tests can be run with `accessibilityChecksEnabled: true`

### Future Plan

* Integrate `accessibility_test` package
* Add CI checks for a11y failures