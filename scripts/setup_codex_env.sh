#!/usr/bin/env bash
set -euo pipefail

echo "🔧  TippmixApp – CI/Local environment bootstrap"

# ────────────────────────────────────────────────
# 1. Flutter SDK
# ────────────────────────────────────────────────
FLUTTER_TAG=3.22.1
if ! command -v flutter &>/dev/null; then
  git clone --depth 1 --branch "$FLUTTER_TAG" https://github.com/flutter/flutter.git
  export PATH="$PWD/flutter/bin:$PATH"
fi
flutter doctor -v

# ────────────────────────────────────────────────
# 2. Node.js + Firebase CLI (for Firestore emulator & tests)
# ────────────────────────────────────────────────
if ! command -v node &>/dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi
npm install -g firebase-tools@latest

# ────────────────────────────────────────────────
# 3. CocoaPods (macOS only – iOS build)
# ────────────────────────────────────────────────
if [[ "$OSTYPE" == "darwin"* ]]; then
  sudo gem install cocoapods || true
  pod repo update || true
fi

# ────────────────────────────────────────────────
# 4. Project dependencies
# ────────────────────────────────────────────────
flutter pub get

# ────────────────────────────────────────────────
# 5. Gyors helyi ellenőrzés (lint + teszt)
# ────────────────────────────────────────────────
./scripts/lint_docs.sh || true
./scripts/precommit.sh || true   # full pre-commit checklist

echo "✅  Environment ready – happy coding! 🎯"
