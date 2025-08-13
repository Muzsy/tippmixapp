import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/social_provider.dart';
import '../providers/auth_provider.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

class FriendRequestButton extends ConsumerWidget {
  final String targetUid;

  const FriendRequestButton({super.key, required this.targetUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authProvider).user?.id;
    if (uid == null || uid == targetUid) {
      return const SizedBox.shrink();
    }
    final requests = ref.watch(friendRequestsProvider(targetUid));
    final alreadySent = requests.when(
      data: (list) => list.any((r) => r.fromUid == uid),
      loading: () => false,
      error: (_, _) => false,
    );
    final loc = AppLocalizations.of(context)!;
    return TextButton(
      onPressed: alreadySent
          ? null
          : () {
              ref.read(socialServiceProvider).sendFriendRequest(targetUid);
            },
      child: Text(alreadySent ? loc.requestSent : loc.addFriend),
    );
  }
}
