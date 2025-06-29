#!/bin/bash
# Simple wrapper to run security rules tests with Firebase emulator
firebase emulators:exec --project demo 'dart test test/integration/security_rules_test.dart'
