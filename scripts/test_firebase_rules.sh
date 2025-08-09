#!/usr/bin/env bash
set -euo pipefail

command -v firebase >/dev/null 2>&1 || npm i -g firebase-tools

echo "📦 Installing dependencies..."
npm ci --prefer-offline

echo "🧪 Running Firestore security rules tests with coverage..."
firebase emulators:exec 'npm run test:rules:coverage'
