import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return _options;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
        return _options;
    }
  }

  static const FirebaseOptions _options = FirebaseOptions(
    apiKey: 'dummy',
    appId: 'dummy',
    messagingSenderId: 'dummy',
    projectId: 'dummy',
  );
}
