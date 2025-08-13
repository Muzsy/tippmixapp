import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_stats_model.dart';

/// Displays the current user's avatar, TippCoin balance, win rate and rank.
class UserStatsHeader extends ConsumerWidget {
  final UserStatsModel? stats;

  const UserStatsHeader({super.key, this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            child: user != null
                ? Text(user.displayName.isNotEmpty ? user.displayName[0] : '?')
                : const Icon(Icons.person),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? loc.profile_guest,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text('${loc.home_coin}: ${stats?.coins ?? 0}'),
                Text('${(stats?.winRate ?? 0) * 100}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
