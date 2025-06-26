import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'auth_provider.dart';

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

final notificationStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  final uid = ref.watch(authProvider).user?.id;
  if (uid == null) {
    return Stream.value([]);
  }
  final service = ref.watch(notificationServiceProvider);
  return service.streamNotifications(uid);
});
