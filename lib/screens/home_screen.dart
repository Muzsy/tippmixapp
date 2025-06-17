import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/widgets/my_bottom_navigation_bar.dart';
import 'package:tippmixapp/widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
        title: Text(AppLocalizations.of(context)!.home_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // Ide jöhet később notification logika
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.notifications)),
              );
            },
            tooltip: AppLocalizations.of(context)!.notifications,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: child,
      bottomNavigationBar: const MyBottomNavigationBar(),
    );
  }
}