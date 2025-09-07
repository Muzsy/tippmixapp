import 'package:flutter/material.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import '../models/notification_model.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.reward:
        return Icons.card_giftcard;
      case NotificationType.badge:
        return Icons.badge;
      case NotificationType.friend:
        return Icons.person_add;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.challenge:
        return Icons.sports_martial_arts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return ListTile(
      leading: Icon(_iconForType(notification.type)),
      title: Text(notification.title),
      subtitle: Text(notification.description),
      trailing: notification.isRead ? null : Text(loc.notificationMarkRead),
      onTap: onTap,
    );
  }
}
