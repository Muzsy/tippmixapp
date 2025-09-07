import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/domain/vote.dart';

import 'forum_repository.dart';

class FirestoreForumRepository implements ForumRepository {
  FirestoreForumRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _threadsCol =>
      _firestore.collection('threads');

  @override
  Stream<List<Thread>> getThreadsByFixture(
    String fixtureId, {
    int limit = 20,
    DateTime? startAfter,
  }) {
    var query = _threadsCol
        .where('fixtureId', isEqualTo: fixtureId)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (startAfter != null) {
      query = query.startAfter([Timestamp.fromDate(startAfter)]);
    }
    return query.snapshots().map(
      (s) => s.docs.map((d) => Thread.fromJson(d.id, d.data())).toList(),
    );
  }

  @override
  Stream<List<Thread>> getRecentThreads({
    int limit = 20,
    DateTime? startAfter,
  }) {
    var query = _threadsCol.orderBy('createdAt', descending: true).limit(limit);
    if (startAfter != null) {
      query = query.startAfter([Timestamp.fromDate(startAfter)]);
    }
    return query.snapshots().map(
      (s) => s.docs.map((d) => Thread.fromJson(d.id, d.data())).toList(),
    );
  }

  @override
  Stream<List<Post>> getPostsByThread(
    String threadId, {
    int limit = 20,
    DateTime? startAfter,
  }) {
    var query = _threadsCol
        .doc(threadId)
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (startAfter != null) {
      query = query.startAfter([Timestamp.fromDate(startAfter)]);
    }
    return query.snapshots().map(
      (s) => s.docs.map((d) => Post.fromJson(d.id, d.data())).toList(),
    );
  }

  @override
  Future<void> addPost(Post post) async {
    await _threadsCol
        .doc(post.threadId)
        .collection('posts')
        .doc(post.id)
        .set(post.toJson());
  }

  @override
  Future<void> voteOnPost({
    required String postId,
    required String userId,
  }) async {
    final vote = Vote(
      id: '${postId}_$userId',
      entityType: VoteEntityType.post,
      entityId: postId,
      userId: userId,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('votes').doc(vote.id).set(vote.toJson());
  }

  @override
  Future<void> reportPost(Report report) async {
    await _firestore.collection('reports').add(report.toJson());
  }
}
