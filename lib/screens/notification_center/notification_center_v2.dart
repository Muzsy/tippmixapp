import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/analytics_service.dart';
import '../../services/notification_handler.dart';
import '../../widgets/notification_preview_card.dart';
import '../../widgets/category_tabs.dart';

class NotificationCenterScreenV2 extends ConsumerStatefulWidget {
  const NotificationCenterScreenV2({super.key});

  @override
  ConsumerState<NotificationCenterScreenV2> createState() =>
      _NotificationCenterScreenV2State();
}

class _NotificationCenterScreenV2State
    extends ConsumerState<NotificationCenterScreenV2>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: NotificationCategory.values.length + 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final notificationsAsync = ref.watch(notificationStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.notificationTitle),
        bottom: CategoryTabs(controller: _controller),
      ),
      body: notificationsAsync.when(
        data: (list) {
          var items = list.where((n) => !n.archived).toList();
          final index = _controller.index;
          if (index > 0) {
            final cat = NotificationCategory.values[index - 1];
            items = items.where((n) => n.category == cat).toList();
          }
          items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          if (items.isEmpty) {
            return Center(child: Text(loc.notificationEmpty));
          }
          return TabBarView(
            controller: _controller,
            children: List.generate(NotificationCategory.values.length + 1, (
              tabIndex,
            ) {
              var filtered = list.where((n) => !n.archived).toList();
              if (tabIndex > 0) {
                final cat = NotificationCategory.values[tabIndex - 1];
                filtered = filtered.where((n) => n.category == cat).toList();
              }
              filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
              if (filtered.isEmpty) {
                return Center(child: Text(loc.notificationEmpty));
              }
              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return Dismissible(
                    key: ValueKey(item.id),
                    background: Container(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onDismissed: (_) {
                      ref
                          .read(notificationServiceProvider)
                          .archive(ref.read(authProvider).user!.id, item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loc.notificationArchive),
                          action: SnackBarAction(
                            label: loc.notificationUndo,
                            onPressed: () {},
                          ),
                        ),
                      );
                    },
                    child: NotificationPreviewCard(
                      notification: item,
                      onTap: () {
                        ref
                            .read(notificationHandlerProvider)
                            .handle(context, item);
                        ref
                            .read(analyticsServiceProvider)
                            .logNotificationOpened(item.category.name);
                        ref
                            .read(notificationServiceProvider)
                            .markAsRead(
                              ref.read(authProvider).user!.id,
                              item.id,
                            );
                      },
                    ),
                  );
                },
              );
            }),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
