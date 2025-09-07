import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import '../routes/app_route.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              loc.drawer_title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dynamic_feed),
            title: Text(loc.drawer_feed),
            onTap: () {
              Navigator.pop(context);
              context.goNamed(AppRoute.feed.name);
            },
          ),
          ListTile(
            leading: const Icon(Icons.sports_soccer),
            title: Text(loc.bets_title),
            onTap: () {
              Navigator.pop(context);
              context.goNamed(AppRoute.bets.name);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(loc.menuProfile),
            onTap: () {
              Navigator.pop(context);
              context.goNamed(AppRoute.profile.name);
            },
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard),
            title: Text(loc.menuLeaderboard),
            onTap: () {
              Navigator.pop(context);
              context.goNamed(AppRoute.leaderboard.name);
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(loc.menuNotifications),
            onTap: () {
              Navigator.pop(context);
              context.goNamed(AppRoute.notifications.name);
            },
          ),
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: Text(loc.menuRewards),
            onTap: () {
              Navigator.pop(context);
              context.goNamed(AppRoute.rewards.name);
            },
          ),
          ListTile(
            leading: const Icon(Icons.badge),
            title: Text(loc.menuBadges),
            onTap: () {
              Navigator.pop(context);
              context.goNamed(AppRoute.badges.name);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text(loc.myTickets),
            onTap: () {
              Navigator.pop(context);
              context.goNamed(AppRoute.myTickets.name);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(loc.menuSettings),
            onTap: () {
              Navigator.pop(context);
              context.goNamed(AppRoute.settings.name);
            },
          ),
        ],
      ),
    );
  }
}
