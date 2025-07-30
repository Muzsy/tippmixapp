import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/friend_request.dart';

class SocialService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SocialService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  Future<void> followUser(String targetUid) async {
    final ref = _firestore
        .collection('relations')
        .doc(targetUid)
        .collection('followers')
        .doc(_uid);
    await ref.set({'uid': _uid});
  }

  Future<void> unfollowUser(String targetUid) async {
    final ref = _firestore
        .collection('relations')
        .doc(targetUid)
        .collection('followers')
        .doc(_uid);
    await ref.delete();
  }

  Stream<List<String>> followersStream(String uid) {
    return _firestore
        .collection('relations')
        .doc(uid)
        .collection('followers')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }

  Future<void> sendFriendRequest(String targetUid) async {
    final col = _firestore
        .collection('relations')
        .doc(targetUid)
        .collection('friendRequests');
    await col.add({'fromUid': _uid, 'toUid': targetUid, 'accepted': false});
  }

  Future<void> acceptFriendRequest(String requestId) async {
    final doc = _firestore
        .collection('relations')
        .doc(_uid)
        .collection('friendRequests')
        .doc(requestId);
    await doc.update({'accepted': true});
  }

  Stream<List<FriendRequest>> friendRequestsStream(String uid) {
    return _firestore
        .collection('relations')
        .doc(uid)
        .collection('friendRequests')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => FriendRequest.fromJson(d.id, d.data()))
              .toList(),
        );
  }
}
