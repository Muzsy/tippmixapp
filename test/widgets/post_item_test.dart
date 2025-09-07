import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/providers/thread_detail_controller.dart';
import 'package:tipsterino/models/user.dart';
import 'package:tipsterino/models/auth_state.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/screens/forum/post_item.dart';

class FakeAuthNotifier extends StateNotifier<AuthState> {
  FakeAuthNotifier(User user) : super(AuthState(user: user));
}

class FakeForumRepository implements ForumRepository {
  bool voteCalled = false;

  @override
  Future<void> voteOnPost({required String postId, required String userId}) async {
    voteCalled = true;
  }

  // Unused methods in test
  @override
  Stream<List<Post>> getPostsByThread(String threadId,
          {int limit = 20, DateTime? startAfter}) =>
      const Stream.empty();

  @override
  Future<void> reportPost(Report report) async {}

  @override
  Future<void> addPost(Post post) async {}

  @override
  Future<void> addThread(Thread thread) async {}

  @override
  Future<void> updateThread(String threadId, Map<String, dynamic> data) async {}

  @override
  Future<void> deleteThread(String threadId) async {}

  @override
  Stream<List<Thread>> getRecentThreads({int limit = 20, DateTime? startAfter}) =>
      const Stream.empty();

  @override
  Stream<List<Thread>> getThreadsByFixture(String fixtureId,
          {int limit = 20, DateTime? startAfter}) =>
      const Stream.empty();

  @override
  Future<void> updatePost(
          {required String threadId,
          required String postId,
          required String content}) async {}

  @override
  Future<void> deletePost(
          {required String threadId, required String postId}) async {}
}

void main() {
  testWidgets('upvote calls repository', (tester) async {
    final repo = FakeForumRepository();
    final post = Post(
      id: 'p1',
      threadId: 't1',
      userId: 'u1',
      type: PostType.comment,
      content: 'Hello',
      createdAt: DateTime.now(),
    );
    final user = User(id: 'u1', email: '', displayName: '');
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authProvider.overrideWith(() => FakeAuthNotifier(user)),
        threadDetailControllerProviderFamily('t1')
            .overrideWith((ref) => ThreadDetailController(repo, 't1')),
      ],
      child: MaterialApp(home: PostItem(post: post)),
    ));

    await tester.tap(find.byIcon(Icons.thumb_up));
    await tester.pump();

    expect(repo.voteCalled, true);
  });
}

