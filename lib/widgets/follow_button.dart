import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/social_provider.dart';
import '../providers/auth_provider.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

class FollowButton extends ConsumerWidget {
  final String targetUid;

  const FollowButton({super.key, required this.targetUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authProvider).user?.id;
    if (uid == null || uid == targetUid) {
      return const SizedBox.shrink();
    }
    final followers = ref.watch(followersProvider(targetUid));
    final isFollowing = followers.when(
      data: (list) => list.contains(uid),
      loading: () => false,
      error: (_, _) => false,
    );
    final loc = AppLocalizations.of(context)!;
    return TextButton(
      onPressed: () {
        final service = ref.read(socialServiceProvider);
        if (isFollowing) {
          service.unfollowUser(targetUid);
        } else {
          service.followUser(targetUid);
        }
      },
      child: Text(isFollowing ? loc.unfollow : loc.follow),
    );
  }
}
