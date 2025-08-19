#!/usr/bin/env bash
set -e
flutter gen-l10n
flutter analyze
flutter test -r compact
