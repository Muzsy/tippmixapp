import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class CategoryTabs extends StatelessWidget implements PreferredSizeWidget {
  const CategoryTabs({super.key, required this.controller});

  final TabController controller;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return TabBar(
      controller: controller,
      isScrollable: true,
      tabs: [
        Tab(text: loc.notificationFilterAll),
        Tab(text: loc.notif_tips),
        Tab(text: loc.notif_friend_activity),
        Tab(text: loc.notif_rewards),
        Tab(text: loc.notif_system),
      ],
    );
  }
}
