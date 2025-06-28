import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/badge_config.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/badge_grid_view.dart';

/// Streams the keys of badges owned by the current user from Firestore.
final userBadgesProvider = StreamProvider<List<String>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    return Stream.value([]);
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('badges')
      .snapshots()
      .map((snap) => snap.docs.map((d) => d.id).toList());
});

enum BadgeFilter { all, owned, missing }

class BadgeScreen extends ConsumerStatefulWidget {
  const BadgeScreen({super.key});

  @override
  ConsumerState<BadgeScreen> createState() => _BadgeScreenState();
}

class _BadgeScreenState extends ConsumerState<BadgeScreen> {
  BadgeFilter _filter = BadgeFilter.owned;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final badgesAsync = ref.watch(userBadgesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.badgeScreenTitle)),
      body: badgesAsync.when(
        data: (owned) {
          final list = badgeConfigs.where((b) {
            final has = owned.contains(b.key);
            switch (_filter) {
              case BadgeFilter.all:
                return true;
              case BadgeFilter.owned:
                return has;
              case BadgeFilter.missing:
                return !has;
            }
          }).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<BadgeFilter>(
                  value: _filter,
                  onChanged: (f) => setState(() => _filter = f ?? BadgeFilter.all),
                  items: [
                    DropdownMenuItem(
                      value: BadgeFilter.all,
                      child: Text(loc.badgeFilterAll),
                    ),
                    DropdownMenuItem(
                      value: BadgeFilter.owned,
                      child: Text(loc.badgeFilterOwned),
                    ),
                    DropdownMenuItem(
                      value: BadgeFilter.missing,
                      child: Text(loc.badgeFilterMissing),
                    ),
                  ],
                ),
              ),
              Expanded(child: BadgeGridView(badges: list)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
