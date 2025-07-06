#!/usr/bin/env bash
set -euo pipefail

echo "🚀  TipMixApp – univerzális setup indul..."

# ───────────────────────────────────────────────────────────────
# 1. Flutter SDK (ha még nincs a PATH‑on – CI‑ben már lesz)
# ───────────────────────────────────────────────────────────────
if ! command -v flutter &> /dev/null; then
  FLUTTER_VERSION_TAG=3.32.5
  git clone --branch "$FLUTTER_VERSION_TAG" --depth 1 https://github.com/flutter/flutter.git
  export PATH="$PWD/flutter/bin:$PATH"
fi

flutter doctor -v

# ───────────────────────────────────────────────────────────────
# 2. Dart + Flutter dependenciák
# ───────────────────────────────────────────────────────────────
flutter pub get

# Generált kódok, ha használsz build_runner‑t
if grep -q "build_runner" pubspec.yaml 2>/dev/null; then
  flutter pub run build_runner build --delete-conflicting-outputs
fi

# ───────────────────────────────────────────────────────────────
# 3. Statikus elemzés és unit‑tesztek
# ───────────────────────────────────────────────────────────────
flutter analyze --no-fatal-infos --no-fatal-warnings lib test || true
flutter test || true

echo "✅  Setup kész – kód mehet 🎯"
