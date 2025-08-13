import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tippmixapp/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/social_provider.dart';
import '../../widgets/follow_button.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final uid = ref.watch(authProvider).user?.id;
    if (uid == null) return const SizedBox.shrink();
    final friends = ref.watch(followersProvider(uid));
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.friends),
        bottom: TabBar(
          controller: _controller,
          tabs: [
            Tab(text: loc.followers),
            Tab(text: loc.pending),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          friends.when(
            data: (list) => ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final id = list[index];
                return ListTile(
                  title: Text(id),
                  trailing: FollowButton(targetUid: id),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const SizedBox.shrink(),
          ),
          Center(
            child: ref
                .watch(friendRequestsProvider(uid))
                .when(
                  data: (list) => ListView(
                    children: list
                        .where((r) => !r.accepted)
                        .map(
                          (r) => ListTile(
                            title: Text(r.fromUid),
                            trailing: TextButton(
                              onPressed: () {
                                ref
                                    .read(socialServiceProvider)
                                    .acceptFriendRequest(r.id);
                              },
                              child: Text(loc.accept),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
          ),
        ],
      ),
    );
  }
}
