import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:tippmixapp/services/coin_service.dart';

class FakeHttpsCallableResult<T> implements HttpsCallableResult<T> {
  @override
  final T data;

  FakeHttpsCallableResult(this.data);
}

class FakeHttpsCallable implements HttpsCallable {
  Map<String, dynamic>? lastData;

  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    lastData = Map<String, dynamic>.from(parameters as Map);
    return FakeHttpsCallableResult<T>(null as T);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeFirebaseFunctions implements FirebaseFunctions {
  final FakeHttpsCallable callable = FakeHttpsCallable();

  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    return callable;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('debitCoin calls cloud function with correct parameters', () async {
    final functions = FakeFirebaseFunctions();
    final service = CoinService(functions);

    await service.debitCoin(
      userId: 'u1',
      amount: 10,
      reason: 'bet',
      transactionId: 't1',
    );

    expect(functions.callable.lastData, isNotNull);
    expect(functions.callable.lastData!['type'], 'debit');
    expect(functions.callable.lastData!['amount'], 10);
  });

  test('creditCoin uses credit type', () async {
    final functions = FakeFirebaseFunctions();
    final service = CoinService(functions);

    await service.creditCoin(
      userId: 'u1',
      amount: 20,
      reason: 'bonus',
      transactionId: 't2',
    );

    expect(functions.callable.lastData!['type'], 'credit');
    expect(functions.callable.lastData!['amount'], 20);
  });
}

