import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/providers/stats_provider.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

class ProfileSummary extends ConsumerWidget {
  const ProfileSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;
    final stats = ref.watch(userStatsProvider).asData?.value;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            child: Text(user?.displayName.isNotEmpty == true
                ? user!.displayName[0]
                : '?'),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
