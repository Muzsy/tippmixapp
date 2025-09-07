import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stats_provider.dart';
import '../../services/reward_service.dart';
import '../../widgets/coins_balance_header.dart';
import '../../widgets/reward_tile.dart';
import '../../widgets/streak_progress_bar.dart';

class RewardsScreenV2 extends ConsumerWidget {
  const RewardsScreenV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final rewards = ref.watch(rewardServiceProvider);
    final me = ref.watch(authProvider).user;
    final statsStream = me == null
        ? const Stream.empty()
        : ref.read(statsServiceProvider).statsDocStream(me.id);

    return Scaffold(
      appBar: AppBar(title: Text(loc.rewardTitle)),
      body: StreamBuilder(
        stream: statsStream,
        builder: (context, snapshot) {
          final stats = snapshot.data;
          return Column(
            children: [
              if (stats != null) ...[
                CoinsBalanceHeader(coins: stats.coinsBalance),
                StreakProgressBar(streakDays: stats.streakDays),
              ],
              Expanded(
                child: rewards.isEmpty
                    ? Center(child: Text(loc.rewardEmpty))
                    : ListView.builder(
                        itemCount: rewards.length,
                        itemBuilder: (context, index) {
                          final reward = rewards[index];
                          return RewardTile(
                            reward: reward,
                            onClaim: () async {
                              await ref
                                  .read(rewardServiceProvider.notifier)
                                  .claimReward(reward);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
