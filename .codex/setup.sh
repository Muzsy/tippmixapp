#!/usr/bin/env bash
set -euo pipefail

# Double-run guard – legyen EZ az első “valódi” kód
if [[ -f /tmp/codex_setup_ran ]]; then
  echo "SETUP DUPLA – már futott egyszer."
  exit 0  # vagy 1, ha direkt hibáztatni akarod
fi
touch /tmp/codex_setup_ran
trap 'rm -f /tmp/codex_setup_ran' EXIT

echo "🚀 TippmixApp – Codex setup indul..."

# 0) Beállítások
FLUTTER_VERSION_TAG="${FLUTTER_VERSION_TAG:-3.32.8}"  # egy helyen definiálva

# 1) Flutter (csak ha nincs)
if ! command -v flutter >/dev/null 2>&1; then
  echo "→ Flutter ${FLUTTER_VERSION_TAG} letöltése..."
  git clone --depth 1 --branch "${FLUTTER_VERSION_TAG}" https://github.com/flutter/flutter.git /opt/flutter
  export PATH="/opt/flutter/bin:$PATH"
else
  # biztosítsuk, hogy a bin a PATH-on van
  export PATH="$(dirname "$(command -v flutter)"):$PATH"
fi
flutter --version

# 2) Firebase CLI (csak ha hiányzik) – Node 22 adott
if ! command -v firebase >/dev/null 2>&1; then
  echo "→ Firebase CLI telepítése..."
  npm i -g firebase-tools@latest
fi
firebase --version || true

# 3) Csomagok
if [ -f "pubspec.yaml" ]; then
  flutter pub get
  if grep -q "build_runner" pubspec.yaml 2>/dev/null; then
    flutter pub run build_runner build --delete-conflicting-outputs
  fi
fi

echo "✅ Codex setup kész."
