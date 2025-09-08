import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/screens/forum/composer_bar.dart';
import 'package:tipsterino/screens/forum/thread_view_screen.dart';
import 'package:tipsterino/features/forum/providers/thread_detail_controller.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/features/forum/providers/forum_filter_state.dart';

class _FakeController extends ThreadDetailController {
  _FakeController() : super(_DummyRepo(), 't1');

  bool addCalled = false;

  @override
  Future<void> addPost(Post post) async {
    addCalled = true;
  }
}

class _DummyRepo implements ForumRepository {
  @override
  Future<void> addPost(Post post) async {}

  @override
  Future<void> addThread(Thread thread) async {}

  @override
  Future<void> deleteThread(String threadId) async {}

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
  Future<void> reportPost(Report report) async {}

  @override
  Future<void> updatePost({
    required String threadId,
    required String postId,
    required String content,
  }) async {}

  @override
  Future<void> deletePost({
    required String threadId,
    required String postId,
  }) async {}

  @override
  Future<void> updateThread(String threadId, Map<String, dynamic> data) async {}

  @override
  Future<void> voteOnPost({required String postId, required String userId}) async {}
}

void main() {
  testWidgets('shows banner and prevents posting when locked', (tester) async {
    final controller = _FakeController();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          threadDetailControllerProviderFamily('t1').overrideWith((ref) => controller),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ThreadViewScreen(threadId: 't1', locked: true),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Thread is locked'), findsOneWidget);
    final composer = tester.widget<ComposerBar>(find.byType(ComposerBar));
    await composer.onSubmit!.call();
    await tester.pump();
    expect(controller.addCalled, isFalse);
  });

  testWidgets('composer enabled when unlocked', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ThreadViewScreen(threadId: 't1'),
    ));
    final sendButton = find.byIcon(Icons.send);
    expect(tester.widget<IconButton>(sendButton).onPressed, isNotNull);
    expect(find.text('Thread is locked'), findsNothing);
  });
}
