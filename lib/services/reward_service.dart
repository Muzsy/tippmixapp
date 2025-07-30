import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/reward_model.dart';

class RewardService extends StateNotifier<List<RewardModel>> {
  RewardService([FirebaseFunctions? functions])
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'europe-central2'),
      super([]);

  final FirebaseFunctions _functions;

  void loadRewards(List<RewardModel> rewards) {
    state = rewards.where((r) => !r.isClaimed).toList();
  }

  Future<void> claimReward(RewardModel reward) async {
    await claimRewardById(reward.id);
    reward.isClaimed = true;
    state = state.where((r) => r.id != reward.id).toList();
  }

  Future<void> claimRewardById(String rewardId) async {
    final callable = _functions.httpsCallable('claim_reward');
    await callable.call(<String, dynamic>{'rewardId': rewardId});
  }
}

final rewardServiceProvider =
    StateNotifierProvider<RewardService, List<RewardModel>>(
      (ref) => RewardService(),
    );
