import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import '../routes/app_route.dart';

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({super.key});

  int _getSelectedIndex(BuildContext context) {
    final state = GoRouterState.of(context);
    final location = state.uri.toString();
    if (location == '/feed') return 1;
    if (location.startsWith('/bets')) return 2;
    if (location == '/my-tickets') return 3;
    if (location == '/profile') return 4;
    return 0; // alap: főoldal
  }

  void _onItemTapped(BuildContext context, int index) {
    final router = GoRouter.maybeOf(context);
    if (router == null) return;
    final routeNames = [
      AppRoute.home.name,
      AppRoute.feed.name,
      AppRoute.bets.name,
      AppRoute.myTickets.name,
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
          icon: const Icon(Icons.sports_soccer),
          label: AppLocalizations.of(context)!.bets_title,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt_long),
          label: AppLocalizations.of(context)!.myTickets,
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