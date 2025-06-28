import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import '../routes/app_route.dart';

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({super.key});

  int _getSelectedIndex(BuildContext context) {
    final state = GoRouterState.of(context);
    final location = state.uri.toString();
    if (location == '/events') return 1;
    if (location == '/profile') return 2;
    return 0; // alap: főoldal
  }

  void _onItemTapped(BuildContext context, int index) {
    final router = GoRouter.maybeOf(context);
    if (router == null) return;
    final routeNames = [
      AppRoute.home.name,
      AppRoute.events.name,
      AppRoute.profile.name,
    ];
    if (index < routeNames.length) {
      router.goNamed(routeNames[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _getSelectedIndex(context),
      onTap: (index) => _onItemTapped(context, index),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: AppLocalizations.of(context)!.home_title,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.dynamic_feed),
          label: AppLocalizations.of(context)!.bottom_nav_feed,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: AppLocalizations.of(context)!.home_nav_profile,
        ),
      ],
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).unselectedWidgetColor,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    );
  }
}