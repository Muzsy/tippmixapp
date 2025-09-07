import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import '../routes/app_route.dart';

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({super.key});

  int _getSelectedIndex(BuildContext context) {
    final state = GoRouterState.of(context);
    final location = state.uri.toString();
    if (location == '/feed') return 1;
    if (location.startsWith('/forum')) return 2;
    if (location.startsWith('/bets')) return 3;
    if (location == '/my-tickets') return 4;
    if (location == '/profile') return 5;
    return 0; // alap: főoldal
  }

  void _onItemTapped(BuildContext context, int index) {
    final router = GoRouter.maybeOf(context);
    if (router == null) return;
    final routeNames = [
      AppRoute.home.name,
      AppRoute.feed.name,
      AppRoute.forum.name,
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
    final loc = AppLocalizations.of(context)!;
    return BottomNavigationBar(
      currentIndex: _getSelectedIndex(context),
      onTap: (index) => _onItemTapped(context, index),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: '',
          tooltip: loc.home_title,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.dynamic_feed),
          label: '',
          tooltip: loc.bottom_nav_feed,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.forum),
          label: '',
          tooltip: loc.home_nav_forum,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.sports_soccer, key: Key('nav_bets')),
          label: '',
          tooltip: loc.bets_title,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt_long, key: Key('nav_my_tickets')),
          label: '',
          tooltip: loc.myTickets,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: '',
          tooltip: loc.home_nav_profile,
        ),
      ],
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).unselectedWidgetColor,
      type: BottomNavigationBarType.fixed,
    );
  }
}
