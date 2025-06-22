import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import '../router.dart';

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({super.key});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location == '/profile') return 1;
    if (location == '/my-tickets') return 2;
    return 0; // alap: főoldal
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.goNamed(AppRoute.home.name);
        break;
      case 1:
        context.goNamed(AppRoute.profile.name);
        break;
      case 2:
        context.goNamed(AppRoute.myTickets.name);
        break;
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
          icon: const Icon(Icons.person),
          label: AppLocalizations.of(context)!.home_nav_profile,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt_long),
          label: AppLocalizations.of(context)!.my_tickets_title,
        ),
      ],
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).unselectedWidgetColor,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    );
  }
}