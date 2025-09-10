import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'env/env.dart';

import 'firebase_options.dart';

const bool kUseEmulator = bool.fromEnvironment('USE_EMULATOR', defaultValue: true);

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase (idempotent-ish in practice; wrap in try-catch)
    try {
      if (!Supabase.instance.isInitialized) {
        await Supabase.initialize(
          url: Env.supabaseUrl,
          anonKey: Env.supabaseAnonKey,
        );
      }
    } catch (e) {
      // If already initialized in tests/hot-reload, ignore
      if (!e.toString().toLowerCase().contains('initialized')) {
        rethrow;
      }
    }

    // Skip Firebase initialization entirely when Supabase mode is active
    final supaMode = const bool.fromEnvironment('USE_SUPABASE', defaultValue: true);
    if (!supaMode) {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    }
    // Build guard: prevent accidental prod usage in emulator mode
    if (kUseEmulator) {
      final pid = DefaultFirebaseOptions.currentPlatform.projectId;
      if (pid.toLowerCase().contains('prod')) {
        throw StateError('Offline/emulator mód mellett PROD Firebase projekt tiltott. (projectId=$pid)');
      }
    }
    if (kUseEmulator && !supaMode) {
      final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      // Auth emulator requires await
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFunctions.instanceFor(region: 'europe-central2').useFunctionsEmulator(host, 5001);
      FirebaseStorage.instance.useStorageEmulator(host, 9199);
      try { await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false); } catch (_) {}
    }
    // App Check – fejlesztői / CI környezetben Debug providerre váltunk,
    // hogy a Cloud Functions 403-at elkerüljük.
    if (kDebugMode && !supaMode) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    }
  } catch (e) {
    // Esetenként az apps.isEmpty false pozitív eredményt ad
    if (!e.toString().contains('already exists')) {
      rethrow;
    }
  }
}
