#!/usr/bin/env bash
set -euo pipefail

echo "🔍  Pre-commit checklist (lokális fejlesztői használatra)"

# Ha CI-ben fut, lépjünk ki figyelmeztetéssel
if [[ "${CI:-}" == "true" ]]; then
  echo "ℹ️  CI környezetben vagy – a precommit.sh nem kötelező itt."
  exit 0
fi

# 0) Docs lint (nem áll le, ha csak figyelmeztetés van)
./scripts/lint_docs.sh || true

# 1) Dart format – hibát dob, ha eltérés van
if ! dart format --set-exit-if-changed . ; then
  echo "❌ Kódformázási eltérés. Futtasd: dart format ."
  exit 1
fi

# 2) Statikus analízis
dart analyze --fatal-infos --fatal-warnings
flutter analyze --fatal-infos --fatal-warnings

# 3) Flutter unit/widget tesztek + coverage
flutter test --coverage

# 4) Firestore rules tesztek (ha van)
if [[ -f scripts/test_firebase_rules.sh ]]; then
  ./scripts/test_firebase_rules.sh
fi

# 5) Cloud Functions unit tesztek (ha van)
if [[ -d cloud_functions ]]; then
  npm ci --prefix cloud_functions
  npm test --prefix cloud_functions
fi

# 6) Ne maradjon nem commitolt változás
if ! git diff --quiet; then
  echo "❌ Lint/format módosított fájlokat. Commitold a változásokat."
  exit 1
fi

echo "🎉  Pre-commit checklist OK (lokálisan)."
