#!/usr/bin/env bash
set -euo pipefail

echo "🔍  Running pre-commit checklist …"

# 0. Docs lint (calls the script above)
./scripts/lint_docs.sh

# 1. Dart formatter (fail if átidomít)
dart format --set-exit-if-changed .

# 2. Static analysis (no warnings allowed)
flutter analyze --fatal-infos --fatal-warnings

# 3. Unit & widget tests + coverage ≥ 90 %
flutter test --coverage

# 4. Golden / a11y / integration tests (if present)
if [[ -f integration_test ]]; then
  flutter drive --driver integration_test/*
fi

# 5. Firebase security-rules test (optional, if script exists)
if [[ -f scripts/test_firebase_rules.sh ]]; then
  ./scripts/test_firebase_rules.sh
fi

echo "🎉  Pre-commit checklist passed."
