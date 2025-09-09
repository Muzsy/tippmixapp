import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/providers/thread_detail_controller.dart';
import 'package:tipsterino/features/forum/providers/forum_filter_state.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/models/auth_state.dart';
import 'package:tipsterino/models/user.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import '../mocks/mock_auth_service.dart';
import 'package:tipsterino/screens/forum/thread_view_screen.dart';

class _LoadMoreDetailController extends ThreadDetailController {
  _LoadMoreDetailController(List<Post> posts)
      : super(_FakeRepo(), 't1') {
    state = AsyncData(posts);
  }

  bool called = false;

  @override
  void loadMore() {
    called = true;
  }
}

class _FakeRepo implements ForumRepository {
  @override
  Stream<List<Post>> getPostsByThread(String threadId,
          {int limit = 20, DateTime? startAfter}) =>
      const Stream.empty();

  @override
  Stream<List<Thread>> queryThreads({
    required ForumFilter filter,
    required ForumSort sort,
    int limit = 20,
    DateTime? startAfter,
  }) => const Stream.empty();

  @override
  Stream<List<Thread>> getThreadsByFixture(String fixtureId,
          {int limit = 20, DateTime? startAfter}) =>
      const Stream.empty();

  @override
  Future<void> addThread(Thread thread) async {}
  @override
  Future<void> updateThread(String threadId, Map<String, dynamic> data) async {}
  @override
  Future<void> deleteThread(String threadId) async {}
  @override
  Future<void> addPost(Post post) async {}
  @override
  Future<void> updatePost({required String threadId, required String postId, required String content}) async {}
  @override
  Future<void> deletePost({required String threadId, required String postId}) async {}
  @override
  Future<void> voteOnPost({required String postId, required String userId}) async {}
  @override
  Future<void> reportPost(Report report) async {}
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier() : super(MockAuthService()) {
    state = AuthState(user: User(id: 'u1', email: '', displayName: ''));
  }
}

void main() {
  testWidgets('scrolling loads more posts', (tester) async {
    final posts = List.generate(
      30,
      (i) => Post(
        id: '$i',
        threadId: 't1',
        userId: 'u1',
        type: PostType.comment,
        content: 'c',
        createdAt: DateTime.now(),
      ),
    );
    final controller = _LoadMoreDetailController(posts);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          threadDetailControllerProviderFamily('t1').overrideWith(
            (ref) => controller,
          ),
          authProvider.overrideWith((ref) => _FakeAuthNotifier()),
        ],
        child: MaterialApp(
          home: const ThreadViewScreen(threadId: 't1'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Scroll far enough towards the end to trigger the threshold
    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pump();
    expect(controller.called, isTrue);
  });
}
