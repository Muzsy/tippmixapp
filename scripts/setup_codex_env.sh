#!/usr/bin/env bash
set -euo pipefail

echo "🔧  TippmixApp – CI/Local environment bootstrap"

# 1) Flutter SDK (egységesítve a CI-vel)
FLUTTER_TAG=3.32.8
if ! command -v flutter &>/dev/null; then
  git clone --depth 1 --branch "$FLUTTER_TAG" https://github.com/flutter/flutter.git
  export PATH="$PWD/flutter/bin:$PATH"
fi
flutter doctor -v

# 2) Node.js + Firebase CLI (lokális fejlesztéshez)
if ! command -v node &>/dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi
if ! command -v firebase &>/dev/null; then
  npm i -g firebase-tools
fi

# 3) CocoaPods (csak macOS/iOS)
if [[ "${OSTYPE:-}" == "darwin"* ]]; then
  sudo gem install cocoapods || true
  pod repo update || true
fi

# 4) Projekt függőségek
flutter pub get

# 5) Gyors ellenőrzés (nem bukik, ha figyelmeztetés)
./scripts/lint_docs.sh || true
./scripts/precommit.sh || true

echo "✅  Environment ready – happy coding! 🎯"
