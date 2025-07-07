import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/social_provider.dart';
import '../providers/auth_provider.dart';

class PendingBadge extends ConsumerWidget {
  const PendingBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authProvider).user?.id;
    if (uid == null) return const SizedBox.shrink();
    final requests = ref.watch(friendRequestsProvider(uid));
    final count = requests.when(
      data: (list) => list.where((r) => !r.accepted).length,
      loading: () => 0,
      error: (_, _) => 0,
    );
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}
