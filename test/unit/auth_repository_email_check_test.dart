import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tippmixapp/services/auth_repository.dart';

class FakeCallable extends Fake implements HttpsCallable {
  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    return FakeResult(null as T);
  }
}

class FakeResult<T> implements HttpsCallableResult<T> {
  @override
  final T data;
  FakeResult(this.data);
}

class FakeFunctions extends Fake implements FirebaseFunctions {
  final HttpsCallable callable;
  FakeFunctions(this.callable);
  @override
  FirebaseApp get app => Firebase.app();
  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) =>
      callable;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  });
  test('isEmailAvailable calls region aware function', () async {
    final callable = FakeCallable();
    final functions = FakeFunctions(callable);
    final repo = AuthRepository(functions: functions);
    await repo.isEmailAvailable('x@y.com');
  });
}
