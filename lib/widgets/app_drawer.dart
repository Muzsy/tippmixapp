import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
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
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dynamic_feed),
            title: Text(loc.menuFeed),
            onTap: () {
              context.goNamed(AppRoute.feed.name);
            },
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard),
            title: Text(loc.menuLeaderboard),
            onTap: () {
              context.goNamed(AppRoute.leaderboard.name);
            },
          ),
            ListTile(
              leading: const Icon(Icons.badge),
              title: Text(loc.menuBadges),
              onTap: () {
                context.goNamed(AppRoute.badges.name);
              },
            ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(loc.menuSettings),
            onTap: () {
              context.goNamed(AppRoute.settings.name);
            },
          ),
        ],
      ),
    );
  }
}
