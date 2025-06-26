import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reward_model.dart';

class RewardService extends StateNotifier<List<RewardModel>> {
  RewardService() : super([]);

  void loadRewards(List<RewardModel> rewards) {
    state = rewards.where((r) => !r.isClaimed).toList();
  }

  Future<void> claimReward(RewardModel reward) async {
    await reward.onClaim();
    reward.isClaimed = true;
    state = state.where((r) => r.id != reward.id).toList();
  }
}

final rewardServiceProvider =
    StateNotifierProvider<RewardService, List<RewardModel>>(
  (ref) => RewardService(),
);
