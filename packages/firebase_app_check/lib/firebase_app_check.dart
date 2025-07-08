class FirebaseAppCheck {
  FirebaseAppCheck._();
  static final FirebaseAppCheck instance = FirebaseAppCheck._();
  Future<void> activate({AndroidProvider androidProvider = AndroidProvider.debug}) async {}
}

enum AndroidProvider { debug, playIntegrity }
