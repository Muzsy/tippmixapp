import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/providers/forum_filter_state.dart';

abstract class ForumRepository {
  Stream<List<Thread>> getThreadsByFixture(
    String fixtureId, {
    int limit = 20,
    DateTime? startAfter,
  });

  Stream<List<Thread>> queryThreads({
    required ForumFilter filter,
    required ForumSort sort,
    int limit = 20,
    DateTime? startAfter,
  });

  Stream<List<Post>> getPostsByThread(
    String threadId, {
    int limit = 20,
    DateTime? startAfter,
  });

  Stream<Thread> watchThread(String threadId);

  Future<void> addThread(Thread thread);

  Future<void> updateThread(String threadId, Map<String, dynamic> data);

  Future<void> deleteThread(String threadId);

  Future<void> addPost(Post post);

  Future<void> updatePost({
    required String threadId,
    required String postId,
    required String content,
  });

  Future<void> deletePost({
    required String threadId,
    required String postId,
  });

  Future<void> voteOnPost({required String postId, required String userId});

  Future<void> unvoteOnPost({required String postId, required String userId});

  Future<bool> hasVoted({required String postId, required String userId});

  Future<void> reportPost(Report report);
}
