import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore;

  NotificationService([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ref(String userId) {
    return _firestore.collection('users/$userId/notifications');
  }

  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return _ref(userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => NotificationModel.fromJson(d.id, d.data()))
              .toList(),
        );
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _ref(userId).doc(notificationId).update({'isRead': true});
  }

  Future<void> archive(String userId, String notificationId) async {
    await _ref(userId).doc(notificationId).update({'archived': true});
  }
}
