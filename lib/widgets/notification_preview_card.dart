import 'package:flutter/material.dart';

import '../models/notification_model.dart';

class NotificationPreviewCard extends StatelessWidget {
  const NotificationPreviewCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: notification.previewUrl != null
          ? Image.network(
              notification.previewUrl!,
              width: 40,
              height: 40,
              semanticLabel: 'notification image',
            )
          : null,
      title: Text(notification.title),
      subtitle: Text(notification.description),
      onTap: onTap,
    );
  }
}
