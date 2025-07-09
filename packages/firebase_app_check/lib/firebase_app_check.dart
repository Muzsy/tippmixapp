class FirebaseAppCheck {
  FirebaseAppCheck._();
  static final FirebaseAppCheck instance = FirebaseAppCheck._();
  Future<void> activate({
    AndroidProvider androidProvider = AndroidProvider.debug,
    AppleProvider appleProvider = AppleProvider.debug,
  }) async {}
}

enum AndroidProvider { debug, playIntegrity }

enum AppleProvider { debug, appStore }
