import 'package:tippmixapp/features/forum/domain/post.dart';
import 'package:tippmixapp/features/forum/domain/report.dart';
import 'package:tippmixapp/features/forum/domain/thread.dart';

abstract class ForumRepository {
  Stream<List<Thread>> getThreadsByFixture(
    String fixtureId, {
    int limit = 20,
    DateTime? startAfter,
  });

  Stream<List<Thread>> getRecentThreads({
    int limit = 20,
    DateTime? startAfter,
  });

  Stream<List<Post>> getPostsByThread(
    String threadId, {
    int limit = 20,
    DateTime? startAfter,
  });

  Future<void> addPost(Post post);

  Future<void> voteOnPost({
    required String postId,
    required int value,
    required String userId,
  });

  Future<void> reportPost(Report report);
}
