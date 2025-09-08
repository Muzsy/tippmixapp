import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/domain/vote.dart';
import 'package:tipsterino/features/forum/providers/forum_filter_state.dart';

import 'thread_query_builder.dart';
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
  Stream<List<Thread>> queryThreads({
    required ForumFilter filter,
    required ForumSort sort,
    int limit = 20,
    DateTime? startAfter,
  }) {
    final params = buildThreadQueryParams(filter, sort);
    Query<Map<String, dynamic>> query = _threadsCol;
    if (params.whereField != null) {
      query = query.where(params.whereField!, isEqualTo: params.whereValue);
    }
    query = query
        .orderBy(params.orderByField, descending: params.descending)
        .limit(limit);
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
  Future<void> addThread(Thread thread) async {
    // createdBy must equal auth.uid per security rules
    await _threadsCol.doc(thread.id).set(thread.toJson());
  }

  @override
  Future<void> updateThread(String threadId, Map<String, dynamic> data) async {
    await _threadsCol.doc(threadId).update(data);
  }

  @override
  Future<void> deleteThread(String threadId) async {
    await _threadsCol.doc(threadId).delete();
  }

  @override
  Future<void> addPost(Post post) async {
    // userId must equal auth.uid per security rules
    await _threadsCol
        .doc(post.threadId)
        .collection('posts')
        .doc(post.id)
        .set(post.toJson());
  }

  @override
  Future<void> updatePost({
    required String threadId,
    required String postId,
    required String content,
  }) async {
    await _threadsCol.doc(threadId).collection('posts').doc(postId).update({
      'content': content,
      'editedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  @override
  Future<void> deletePost({
    required String threadId,
    required String postId,
  }) async {
    await _threadsCol.doc(threadId).collection('posts').doc(postId).delete();
  }

  @override
  Future<void> voteOnPost({
    required String postId,
    required String userId,
  }) async {
    // userId must equal auth.uid; vote id ensures idempotency
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
    // reporterId must equal auth.uid per security rules
    await _firestore.collection('reports').add(report.toJson());
  }
}
