import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:tippmixapp/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class ThrowingCallable extends Fake implements HttpsCallable {
  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    throw FirebaseFunctionsException(code: 'permission-denied', message: '');
  }
}

class FakeFunctions extends Fake implements FirebaseFunctions {
  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    return ThrowingCallable();
  }
}

class FakeFirebaseAuth extends Fake implements fb.FirebaseAuth {}

void main() {
  test('validateNicknameUnique returns true on permission-denied', () async {
    final service = AuthService(
      firebaseAuth: FakeFirebaseAuth(),
      facebookAuth: FacebookAuth.instance,
      functions: FakeFunctions(),
    );
    final result = await service.validateNicknameUnique('nick');
    expect(result, isTrue);
  });
}
