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
    await _firestore.collection('users').doc(uid).set({
      'notificationPreferences': prefs,
    }, SetOptions(merge: true));
    final snap = await _firestore.collection('users').doc(uid).get();
    final data = snap.data() ?? <String, dynamic>{};
    return UserModel.fromJson(data);
  }

  Future<UserModel> updateProfile(
    String uid,
    Map<String, dynamic> changes,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set(changes, SetOptions(merge: true));
    final snap = await _firestore.collection('users').doc(uid).get();
    return UserModel.fromJson(snap.data() ?? <String, dynamic>{});
  }

  Future<void> markOnboardingCompleted(String uid) async {
    await _firestore.collection('users').doc(uid).set({
      'onboardingCompleted': true,
      'onboardingCompletedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
