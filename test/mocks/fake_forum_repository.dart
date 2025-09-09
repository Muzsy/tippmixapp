import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/providers/forum_filter_state.dart';

class FakeForumRepository implements ForumRepository {
  @override
  Stream<List<Thread>> getThreadsByFixture(String fixtureId,
          {int limit = 20, DateTime? startAfter}) =>
      const Stream.empty();

  @override
  Stream<List<Thread>> queryThreads(
          {required ForumFilter filter,
          required ForumSort sort,
          int limit = 20,
          DateTime? startAfter}) =>
      const Stream.empty();

  @override
  Stream<List<Post>> getPostsByThread(String threadId,
          {int limit = 20, DateTime? startAfter}) =>
      const Stream.empty();

  @override
  Stream<Thread> watchThread(String threadId) => const Stream.empty();

  @override
  Future<void> addThread(Thread thread) async {}

  @override
  Future<void> updateThread(String threadId, Map<String, dynamic> data) async {}

  @override
  Future<void> setThreadPinned(String threadId, bool pinned) async {}

  @override
  Future<void> setThreadLocked(String threadId, bool locked) async {}

  @override
  Future<void> deleteThread(String threadId) async {}

  @override
  Future<void> addPost(Post post) async {}

  @override
  Future<void> updatePost(
          {required String threadId,
          required String postId,
          required String content}) async {}

  @override
  Future<void> deletePost(
          {required String threadId, required String postId}) async {}

  @override
  Future<void> voteOnPost({required String postId, required String userId}) async {}

  @override
  Future<void> unvoteOnPost({required String postId, required String userId}) async {}

  @override
  Future<bool> hasVoted(
          {required String postId, required String userId}) async =>
      false;

  @override
  Future<void> reportPost(Report report) async {}
}

