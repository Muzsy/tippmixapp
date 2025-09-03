import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:tippmixapp/services/finalizer_service.dart';

class FakeHttpsCallableResult<T> implements HttpsCallableResult<T> {
  @override
  final T data;
  FakeHttpsCallableResult(this.data);
}

class FakeHttpsCallable extends Fake implements HttpsCallable {
  Map<String, dynamic>? last;
  final dynamic response;
  final bool shouldThrow;
  FakeHttpsCallable({this.response = const {'status': 'OK'}, this.shouldThrow = false});

  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    last = Map<String, dynamic>.from(parameters as Map);
    if (shouldThrow) {
      throw FirebaseFunctionsException(
        code: 'permission-denied',
        message: 'denied',
      );
    }
    return FakeHttpsCallableResult<T>(response as T);
  }
}

class FakeFirebaseFunctions extends Fake implements FirebaseFunctions {
  final FakeHttpsCallable callable;
  FakeFirebaseFunctions(this.callable);

  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    return callable;
  }
}

void main() {
  test('returns OK on success', () async {
    final callable = FakeHttpsCallable();
    final functions = FakeFirebaseFunctions(callable);
    final result = await FinalizerService.forceFinalizer(functions: functions);
    expect(result, 'OK');
    expect(callable.last, {'devOverride': false});
  });

  test('returns error string on failure', () async {
    final callable = FakeHttpsCallable(shouldThrow: true);
    final functions = FakeFirebaseFunctions(callable);
    final result = await FinalizerService.forceFinalizer(functions: functions);
    expect(result.startsWith('ERROR'), isTrue);
  });
}
