import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:tippmixapp/models/reward_model.dart';
import 'package:tippmixapp/services/reward_service.dart';

class FakeHttpsCallable extends Fake implements HttpsCallable {
  Map<String, dynamic>? last;

  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    last = Map<String, dynamic>.from(parameters as Map);
    return FakeHttpsCallableResult<T>(null as T);
  }
}

class FakeHttpsCallableResult<T> extends Fake implements HttpsCallableResult<T> {
  FakeHttpsCallableResult(this.data);
  @override
  final T data;
}

class FakeFirebaseFunctions extends Fake implements FirebaseFunctions {
  final FakeHttpsCallable callable = FakeHttpsCallable();
  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    return callable;
  }
}

void main() {
  test('claimReward marks reward and removes it from state', () async {
    final service = RewardService();
    final reward = RewardModel(
      id: 'r1',
      type: 'daily',
      title: 'Daily',
      description: '',
      iconName: 'coin',
      isClaimed: false,
      onClaim: () async {},
    );

    service.loadRewards([reward]);

    expect(service.state.length, 1);

    await service.claimReward(reward);

    expect(service.state, isEmpty);
    expect(reward.isClaimed, isTrue);
  });

  test('claimRewardById calls cloud function', () async {
    final functions = FakeFirebaseFunctions();
    final service = RewardService(functions);

    await service.claimRewardById('r42');

    expect(functions.callable.last!['rewardId'], 'r42');
  });
}
