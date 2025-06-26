import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/models/reward_model.dart';
import 'package:tippmixapp/services/reward_service.dart';

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
}
