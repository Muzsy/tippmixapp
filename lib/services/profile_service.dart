import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ProfileService {
  const ProfileService._();

  static Future<void> createUserProfile(UserModel user) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(user.toJson());
  }

  static Stream<UserModel?> streamUserProfile(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((snap) => snap.data() == null ? null : UserModel.fromJson(snap.data()!));
}
