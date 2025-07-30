import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/reward_model.dart';

class RewardCard extends StatelessWidget {
  final RewardModel reward;
  final VoidCallback onClaim;

  const RewardCard({super.key, required this.reward, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      child: ListTile(
        leading: Icon(_iconFor(reward.iconName)),
        title: Text(reward.title),
        subtitle: Text(reward.description),
        trailing: reward.isClaimed
            ? Text(loc.rewardClaimed)
            : ElevatedButton(onPressed: onClaim, child: Text(loc.rewardClaim)),
      ),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'coin':
        return Icons.attach_money;
      case 'badge':
        return Icons.emoji_events;
      default:
        return Icons.card_giftcard;
    }
  }
}
