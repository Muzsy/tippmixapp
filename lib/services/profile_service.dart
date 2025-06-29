import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ProfileService {
  const ProfileService._();

  static final List<_QueuedUpdate> _queued = [];

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

  static Future<UserModel> getProfile({
    required String uid,
    required FirebaseFirestore firestore,
    required dynamic cache,
    required dynamic connectivity,
  }) async {
    final online = connectivity.online as bool? ?? true;
    if (!online) {
      final cached = cache.get(uid) as UserModel?;
      if (cached == null) {
        throw const ProfileServiceException.noCache();
      }
      return cached;
    }

    final snap = await firestore.collection('users').doc(uid).get();
    final data = snap.data();
    if (data == null) {
      throw const ProfileServiceException.noCache();
    }
    final user = UserModel.fromJson(data);
    cache.set(uid, user, const Duration(hours: 1));
    return user;
  }

  static Future<void> updateProfile({
    required String uid,
    required Map<String, dynamic> data,
    required FirebaseFirestore firestore,
    required dynamic cache,
    required dynamic connectivity,
  }) async {
    final online = connectivity.online as bool? ?? true;
    if (!online) {
      _queued.add(_QueuedUpdate(uid, data));
      return;
    }

    try {
      await firestore.collection('users').doc(uid).update(data);
    } on FirebaseException catch (_) {
      throw ProfileUpdateFailure();
    }

    final cached = cache.get(uid) as UserModel?;
    if (cached != null) {
      final updated = UserModel(
        uid: cached.uid,
        email: data['email'] ?? cached.email,
        displayName: data['displayName'] ?? cached.displayName,
      );
      cache.set(uid, updated, const Duration(hours: 1));
    } else {
      final snap = await firestore.collection('users').doc(uid).get();
      final newData = snap.data();
      if (newData != null) {
        cache.set(uid, UserModel.fromJson(newData), const Duration(hours: 1));
      }
    }
  }

  static Future<void> flushQueuedUpdates({
    required FirebaseFirestore firestore,
    required dynamic cache,
    required dynamic connectivity,
  }) async {
    if (!(connectivity.online as bool? ?? true)) return;
    for (final q in List<_QueuedUpdate>.from(_queued)) {
      await firestore.collection('users').doc(q.uid).update(q.data);
      final cached = cache.get(q.uid) as UserModel?;
      if (cached != null) {
        final updated = UserModel(
          uid: cached.uid,
          email: q.data['email'] ?? cached.email,
          displayName: q.data['displayName'] ?? cached.displayName,
        );
        cache.set(q.uid, updated, const Duration(hours: 1));
      }
    }
    _queued.clear();
  }
}

class _QueuedUpdate {
  final String uid;
  final Map<String, dynamic> data;
  _QueuedUpdate(this.uid, this.data);
}

class ProfileUpdateFailure implements Exception {}

class ProfileServiceException implements Exception {
  const ProfileServiceException.noCache();
}
