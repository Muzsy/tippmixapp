#!/usr/bin/env bash
set -euo pipefail

echo "🔍  Running pre-commit checklist …"

# 0. Docs lint (calls the script above)
./scripts/lint_docs.sh

# 1. Dart formatter (fail if átidomít)
dart format .

# 2. Statikus analízis (fail, ha warning is van)
dart analyze --fatal-infos --fatal-warnings

# 3. Static analysis (no warnings allowed)
flutter analyze --fatal-infos --fatal-warnings

# 4. Unit & widget tests + coverage ≥ 90 %
flutter test --coverage

# 5. Golden / a11y / integration tests (if present)
if [[ -f integration_test ]]; then
  flutter drive --driver integration_test/*
fi

# 6. Firebase security-rules test (optional, if script exists)
if [[ -f scripts/test_firebase_rules.sh ]]; then
  ./scripts/test_firebase_rules.sh
fi

# 7. Fail only if maradt bármi formázatlan / autofix után is változna
if ! git diff --quiet; then
  echo "❌ Még mindig vannak nem commitolt változások a format/lint után."
  echo "   Futtasd lokálisan: dart format . && ./scripts/lint_docs.sh, majd commit."
  exit 1
fi

echo "🎉  Pre-commit checklist passed."
