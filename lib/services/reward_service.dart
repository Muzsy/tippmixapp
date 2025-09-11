import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reward_model.dart';

class RewardService extends StateNotifier<List<RewardModel>> {
  RewardService() : super(const []);

  void loadRewards(List<RewardModel> rewards) {
    state = List<RewardModel>.from(rewards);
  }

  Future<void> claimReward(RewardModel reward) async {
    await reward.onClaim();
    reward.isClaimed = true;
    state = state.where((r) => r.id != reward.id).toList();
  }

  Future<void> claimRewardById(String rewardId) async {
    final idx = state.indexWhere((r) => r.id == rewardId);
    if (idx == -1) return;
    await claimReward(state[idx]);
  }
}

final rewardServiceProvider =
    StateNotifierProvider<RewardService, List<RewardModel>>(
      (ref) => RewardService(),
    );
