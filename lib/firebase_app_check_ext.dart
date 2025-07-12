import 'package:firebase_app_check/firebase_app_check.dart';

/// Optional interface for custom implementations supporting debug tokens.
abstract class FirebaseAppCheckWithToken {
  Future<void> setToken(String token, {bool isDebug = false});
}

extension FirebaseAppCheckDebug on FirebaseAppCheck {
  Future<void> setToken(String token, {bool isDebug = false}) async {
    if (this is FirebaseAppCheckWithToken) {
      await (this as FirebaseAppCheckWithToken)
          .setToken(token, isDebug: isDebug);
    }
    // no-op otherwise
  }
}
