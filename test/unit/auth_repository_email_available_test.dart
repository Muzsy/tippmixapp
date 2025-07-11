import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:tippmixapp/services/auth_repository.dart';

class FakeHttpsCallable extends Fake implements HttpsCallable {
  dynamic result;
  FakeHttpsCallable(this.result);
  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    if (result is Exception) throw result as Exception;
    return _FakeCallableResult(result as T);
  }
}

class _FakeCallableResult<T> implements HttpsCallableResult<T> {
  @override
  final T data;
  _FakeCallableResult(this.data);
}

class FakeFirebaseFunctions extends Fake implements FirebaseFunctions {
  final HttpsCallable callable;
  FakeFirebaseFunctions(this.callable);
  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    return callable;
  }
}

void main() {
  test('returns true when callable succeeds', () async {
    final functions = FakeFirebaseFunctions(FakeHttpsCallable(null));
    final repo = AuthRepository(functions: functions);
    final result = await repo.isEmailAvailable('a@b.com');
    expect(result, isTrue);
  });

  test('throws EmailAlreadyInUseFailure on 409', () async {
    final exception = FirebaseFunctionsException(
      code: 'already-exists',
      message: 'conflict',
      details: 409,
    );
    final functions = FakeFirebaseFunctions(FakeHttpsCallable(exception));
    final repo = AuthRepository(functions: functions);
    expect(
      () => repo.isEmailAvailable('a@b.com'),
      throwsA(isA<EmailAlreadyInUseFailure>()),
    );
  });
}
