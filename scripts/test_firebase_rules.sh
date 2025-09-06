#!/usr/bin/env bash
set -euo pipefail

if ! command -v firebase >/dev/null 2>&1; then
  if command -v pnpm >/dev/null 2>&1; then
    pnpm dlx firebase-tools --version >/dev/null
  else
    npm i -g firebase-tools
  fi
fi

echo "📦 Installing dependencies..."
if command -v pnpm >/dev/null 2>&1; then
  pnpm install --frozen-lockfile || pnpm install
else
  npm ci --prefer-offline || npm install
fi

echo "🧪 Running Firestore security rules tests with coverage..."
if command -v pnpm >/dev/null 2>&1; then
  firebase emulators:exec "pnpm run test:rules:coverage"
else
  firebase emulators:exec 'npm run test:rules:coverage'
fi
