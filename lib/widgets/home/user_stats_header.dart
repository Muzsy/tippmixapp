import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stats_provider.dart';

/// Displays the current user's avatar, TippCoin balance, win rate and rank.
class UserStatsHeader extends ConsumerWidget {
  const UserStatsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;
    final statsAsync = ref.watch(leaderboardStreamProvider);

    return statsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (list) {
        final idx = user == null ? -1 : list.indexWhere((s) => s.uid == user.id);
        final stats = idx != -1 ? list[idx] : null;
        final rank = idx != -1 ? idx + 1 : null;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: user != null
                    ? Text(user.displayName.isNotEmpty
                        ? user.displayName[0]
                        : '?')
                    : const Icon(Icons.person),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.displayName ?? loc.profile_guest,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('${loc.home_coin}: ${stats?.coins ?? 0}'),
                    Text('${(stats?.winRate ?? 0) * 100}%'),
                  ],
                ),
              ),
              if (rank != null)
                Chip(label: Text('#$rank')),
            ],
          ),
        );
      },
    );
  }
}
