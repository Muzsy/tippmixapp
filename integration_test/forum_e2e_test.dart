import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';

import '../test/mocks/fake_forum_repository.dart';

class _MemoryForumRepository extends FakeForumRepository {
  bool isModerator = true;
  final Map<String, Thread> threads = {};
  final Map<String, List<Post>> posts = {};
  final Map<String, Set<String>> votes = {};

  @override
  Future<void> addThread(Thread thread) async {
    threads[thread.id] = thread;
  }

  @override
  Future<void> addPost(Post post) async {
    posts.putIfAbsent(post.threadId, () => []).add(post);
  }

  @override
  Future<void> voteOnPost({required String postId, required String userId}) async {
    votes.putIfAbsent(postId, () => <String>{}).add(userId);
  }

  @override
  Future<void> reportPost(Report report) async {}

  @override
  Future<void> setThreadPinned(String threadId, bool pinned) async {
    final t = threads[threadId];
    if (t != null) {
      threads[threadId] = t.copyWith(pinned: pinned);
    }
  }

  @override
  Future<void> setThreadLocked(String threadId, bool locked) async {
    final t = threads[threadId];
    if (t != null) {
      threads[threadId] = t.copyWith(locked: locked);
    }
  }

  @override
  Future<void> deletePost({required String threadId, required String postId}) async {
    if (!isModerator) throw const ForumPermissionException();
    posts[threadId]?.removeWhere((p) => p.id == postId);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('forum moderation happy path', (tester) async {
    final repo = _MemoryForumRepository();
    final now = DateTime.now();

    final thread = Thread(
      id: 't1',
      title: 'Test',
      type: ThreadType.general,
      createdBy: 'mod',
      createdAt: now,
      lastActivityAt: now,
    );
    await repo.addThread(thread);

    final post = Post(
      id: 'p1',
      threadId: thread.id,
      userId: 'u1',
      type: PostType.comment,
      content: 'hello',
      createdAt: now,
    );
    await repo.addPost(post);

    await repo.voteOnPost(postId: post.id, userId: 'u2');
    expect(repo.votes[post.id]!.length, 1);

    final report = Report(
      id: 'r1',
      entityType: ReportEntityType.post,
      entityId: post.id,
      reason: 'spam',
      reporterId: 'u2',
      createdAt: now,
    );
    await repo.reportPost(report);

    await repo.setThreadPinned(thread.id, true);
    expect(repo.threads[thread.id]!.pinned, isTrue);

    await repo.setThreadLocked(thread.id, true);
    expect(repo.threads[thread.id]!.locked, isTrue);

    await repo.setThreadLocked(thread.id, false);
    await repo.setThreadPinned(thread.id, false);
    expect(repo.threads[thread.id]!.locked, isFalse);
    expect(repo.threads[thread.id]!.pinned, isFalse);

    repo.isModerator = false;
    expect(
      () => repo.deletePost(threadId: thread.id, postId: post.id),
      throwsA(isA<ForumPermissionException>()),
    );

    repo.isModerator = true;
    await repo.deletePost(threadId: thread.id, postId: post.id);
    expect(repo.posts[thread.id]!.isEmpty, isTrue);
  });
}
