import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import '../../models/leaderboard_mode.dart';
import '../../models/user_stats_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stats_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final me = ref.watch(authProvider).user;
    final statsAsync = ref.watch(leaderboardStreamProvider);
    final mode = ref.watch(leaderboardModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.leaderboard_title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<LeaderboardMode>(
              value: mode,
              onChanged: (m) {
                if (m != null) {
                  ref.read(leaderboardModeProvider.notifier).state = m;
                }
              },
              items: LeaderboardMode.values
                  .map(
                    (m) => DropdownMenuItem(
                      value: m,
                      child: Text(_modeText(loc, m)),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: statsAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return Center(child: Text(loc.leaderboard_empty));
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final isMe = me?.id == item.uid;
                    return ListTile(
                      leading: Text('${index + 1}.'),
                      title: Text(
                        isMe
                            ? '${loc.leaderboard_you} (${item.displayName})'
                            : item.displayName,
                        style: TextStyle(
                          fontWeight: isMe
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(_subtitle(loc, item, mode)),
                      tileColor: isMe
                          ? Theme.of(context).colorScheme.tertiaryContainer
                          : null,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }

  String _modeText(AppLocalizations loc, LeaderboardMode mode) {
    switch (mode) {
      case LeaderboardMode.byCoin:
        return loc.leaderboard_mode_coin;
      case LeaderboardMode.byWinrate:
        return loc.leaderboard_mode_winrate;
      case LeaderboardMode.byStreak:
        return loc.leaderboard_mode_streak;
    }
  }

  String _subtitle(
    AppLocalizations loc,
    UserStatsModel stats,
    LeaderboardMode mode,
  ) {
    switch (mode) {
      case LeaderboardMode.byCoin:
        return '${stats.coins} ${loc.home_coin}';
      case LeaderboardMode.byWinrate:
        return '${(stats.winRate * 100).toStringAsFixed(1)}%';
      case LeaderboardMode.byStreak:
        return '${stats.currentWinStreak ?? 0}';
    }
  }
}
