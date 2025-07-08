import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/reward_model.dart';

class RewardTile extends StatelessWidget {
  final RewardModel reward;
  final VoidCallback onClaim;
  const RewardTile({super.key, required this.reward, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return ListTile(
      leading: Icon(Icons.card_giftcard),
      title: Text(reward.title),
      subtitle: Text(reward.description),
      trailing: reward.isClaimed
          ? Text(loc.rewardClaimed)
          : ElevatedButton(
              onPressed: onClaim,
              child: Text(loc.rewardClaim),
            ),
    );
  }
}
