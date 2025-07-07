import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore;
  UserService([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<UserModel> updateNotificationPrefs(
    String uid,
    Map<String, bool> prefs,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set({'notificationPreferences': prefs}, SetOptions(merge: true));
    final snap = await _firestore.collection('users').doc(uid).get();
    final data = snap.data() ?? <String, dynamic>{};
    return UserModel.fromJson(data);
  }
}
