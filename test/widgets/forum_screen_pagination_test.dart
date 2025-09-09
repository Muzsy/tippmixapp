import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/providers/forum_filter_state.dart';
import 'package:tipsterino/features/forum/providers/thread_list_controller.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/screens/forum/forum_screen.dart';

class _LoadMoreController extends ThreadListController {
  _LoadMoreController(List<Thread> threads)
      : super(_FakeRepo(), const ForumFilterState()) {
    state = AsyncData(threads);
  }

  bool called = false;

  @override
  void loadMore() {
    called = true;
  }
}

class _FakeRepo implements ForumRepository {
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
  Stream<List<Post>> getPostsByThread(String threadId,
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

void main() {
  testWidgets('scrolling triggers loadMore', (tester) async {
    final threads = List.generate(
      30,
      (i) => Thread(
        id: '$i',
        title: 'T$i',
        type: ThreadType.general,
        createdBy: 'u',
        createdAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
      ),
    );
    final controller = _LoadMoreController(threads);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          threadListControllerProvider.overrideWith((ref) => controller),
        ],
        child: MaterialApp(
          home: const ForumScreen(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Scroll near the end to trigger the listener threshold
    final listFinder = find.byType(ListView);
    await tester.dragUntilVisible(
      find.text('T29'),
      listFinder,
      const Offset(0, -300),
    );
    await tester.pump();
    expect(controller.called, isTrue);
  });
}
