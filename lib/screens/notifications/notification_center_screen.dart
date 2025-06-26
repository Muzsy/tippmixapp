import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/notification_provider.dart';
import '../../routes/app_route.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/notification_item.dart';
import '../rewards/rewards_screen.dart';
import '../badges/badge_screen.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final notificationsAsync = ref.watch(notificationStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.notificationTitle)),
      body: notificationsAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text(loc.notificationEmpty));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return NotificationItem(
                notification: item,
                onTap: () {
                  switch (item.type) {
                    case NotificationType.reward:
                      context.goNamed(AppRoute.rewards.name);
                      break;
                    case NotificationType.badge:
                      context.goNamed(AppRoute.badges.name);
                      break;
                    default:
                      context.goNamed(AppRoute.home.name);
                  }
                  ref
                      .read(notificationServiceProvider)
                      .markAsRead(ref.read(authProvider).user!.id, item.id);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
