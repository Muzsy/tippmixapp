import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/reward_model.dart';
import '../../services/reward_service.dart';
import '../../widgets/reward_card.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final rewards = ref.watch(rewardServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.rewardTitle)),
      body: rewards.isEmpty
          ? Center(child: Text(loc.rewardEmpty))
          : ListView.builder(
              itemCount: rewards.length,
              itemBuilder: (context, index) {
                final reward = rewards[index];
                return RewardCard(
                  reward: reward,
                  onClaim: () async {
                    await ref
                        .read(rewardServiceProvider.notifier)
                        .claimReward(reward);
                  },
                );
              },
            ),
    );
  }
}
