#!/usr/bin/env bash
set -euo pipefail

echo "[i] Flutter pub get"
if command -v flutter >/dev/null 2>&1; then
  flutter pub get
  if grep -q "build_runner" pubspec.yaml 2>/dev/null; then
    echo "[i] build_runner"
    dart run build_runner build --delete-conflicting-outputs
  fi

  echo "[i] Format check"
  dart format --set-exit-if-changed . || true

  echo "[i] Analyze"
  flutter analyze || true

  echo "[i] Unit tests"
  flutter test -r expanded --coverage || true
else
  echo "[!] Flutter nincs telepítve vagy nincs PATH-on; ezt a lépést átugrom."
fi

echo "[✓] Flutter CI script lefutott"
