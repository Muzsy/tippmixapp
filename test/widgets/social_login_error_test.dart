import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tippmixapp/widgets/social_login_buttons.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:tippmixapp/models/user.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:tippmixapp/theme/brand_colors_presets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

class FakeFirebaseAuth extends Fake implements fb.FirebaseAuth {}

class CancelFacebookAuthService extends AuthService {
  CancelFacebookAuthService()
    : super(
        firebaseAuth: FakeFirebaseAuth(),
        functions: FakeFunctions(),
        facebookAuth: FakeFacebook(),
        appCheck: FakeFirebaseAppCheck(),
      );

  @override
  Future<User?> signInWithFacebook() async {
    throw AuthServiceException('auth/facebook-cancelled');
  }

  @override
  Future<User?> signInWithGoogle() async => null;

  @override
  Future<User?> signInWithApple() async => null;
}

class FakeFunctions extends Fake implements FirebaseFunctions {
  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    return _NoopCallable();
  }
}

class _NoopCallable extends Fake implements HttpsCallable {
  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    return FakeHttpsCallableResult(null as T);
  }
}

class FakeHttpsCallableResult<T> implements HttpsCallableResult<T> {
  @override
  final T data;
  FakeHttpsCallableResult(this.data);
}

class FakeFacebook extends Fake implements FacebookAuth {}

class FakeFirebaseAppCheck extends Fake implements FirebaseAppCheck {}

void main() {
  testWidgets('shows snackbar when Facebook login cancelled', (tester) async {
    final service = CancelFacebookAuthService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          theme: ThemeData(extensions: const [brandColorsLight]),
          home: const Scaffold(body: SocialLoginButtons()),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('facebook_login_button')));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
