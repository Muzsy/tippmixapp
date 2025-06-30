#!/bin/bash
# test_firebase_rules.sh – CI-compatible wrapper for Firestore rules testing
set -e

echo "📦 Installing dependencies..."
npm ci --prefer-offline

echo "🧪 Running Firestore security rules tests with coverage..."
npm run test:rules:coverage
