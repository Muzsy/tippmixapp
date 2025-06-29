import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/notification_provider.dart';
import '../../routes/app_route.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/notification_item.dart';
// import '../rewards/rewards_screen.dart';
// import '../badges/badge_screen.dart';
import '../../models/notification_model.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen> {
  bool _showUnreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final notificationsAsync = ref.watch(notificationStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.notificationTitle)),
      body: notificationsAsync.when(
        data: (list) {
          var items = List<NotificationModel>.from(list);
          if (_showUnreadOnly) {
            items = items.where((n) => !n.isRead).toList();
          }
          items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (items.isEmpty) {
            return Center(child: Text(loc.notificationEmpty));
          }

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _showUnreadOnly = false),
                    child: Text(loc.notificationFilterAll),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _showUnreadOnly = true),
                    child: Text(loc.notificationFilterUnread),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return NotificationItem(
                      notification: item,
                      onTap: () {
                        final router = GoRouter.maybeOf(context);
                        if (router != null) {
                          switch (item.type) {
                            case NotificationType.reward:
                              router.goNamed(AppRoute.rewards.name);
                              break;
                            case NotificationType.badge:
                              router.goNamed(AppRoute.badges.name);
                              break;
                            default:
                              router.goNamed(AppRoute.home.name);
                          }
                        }
                        ref
                            .read(notificationServiceProvider)
                            .markAsRead(ref.read(authProvider).user!.id, item.id);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
