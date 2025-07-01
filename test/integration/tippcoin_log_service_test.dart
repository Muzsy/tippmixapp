import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:tippmixapp/services/tippcoin_log_service.dart';

class FakeHttpsCallableResult<T> implements HttpsCallableResult<T> {
  @override
  final T data;
  FakeHttpsCallableResult(this.data);
}

class FakeHttpsCallable extends Fake implements HttpsCallable {
  Map<String, dynamic>? lastData;
  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    lastData = Map<String, dynamic>.from(parameters as Map);
    return FakeHttpsCallableResult<T>({} as T);
  }
}

class FakeFirebaseFunctions extends Fake implements FirebaseFunctions {
  final FakeHttpsCallable callable = FakeHttpsCallable();
  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    return callable;
  }
}

void main() {
  group('TippCoinLogService', () {
    test('logCredit sends positive amount', () async {
      final functions = FakeFirebaseFunctions();
      final service = TippCoinLogService(functions);

      await service.logCredit(userId: 'u1', amount: 200, type: 'deposit');

      expect(functions.callable.lastData!['amount'], 200);
      expect(functions.callable.lastData!['type'], 'deposit');
    });

    test('logDebit sends negative amount', () async {
      final functions = FakeFirebaseFunctions();
      final service = TippCoinLogService(functions);

      await service.logDebit(userId: 'u1', amount: -75, type: 'bet');

      expect(functions.callable.lastData!['amount'], -75);
      expect(functions.callable.lastData!['type'], 'bet');
    });
  });
}
