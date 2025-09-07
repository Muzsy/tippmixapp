import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';

abstract class ForumRepository {
  Stream<List<Thread>> getThreadsByFixture(
    String fixtureId, {
    int limit = 20,
    DateTime? startAfter,
  });

  Stream<List<Thread>> getRecentThreads({int limit = 20, DateTime? startAfter});

  Stream<List<Post>> getPostsByThread(
    String threadId, {
    int limit = 20,
    DateTime? startAfter,
  });

  Future<void> addThread(Thread thread);

  Future<void> updateThread(String threadId, Map<String, dynamic> data);

  Future<void> deleteThread(String threadId);

  Future<void> addPost(Post post);

  Future<void> voteOnPost({required String postId, required String userId});

  Future<void> reportPost(Report report);
}
