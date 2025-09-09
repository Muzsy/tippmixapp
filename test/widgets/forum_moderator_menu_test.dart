import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/providers/thread_detail_controller.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/screens/forum/thread_view_screen.dart';

class _FakeController extends ThreadDetailController {
  _FakeController() : super(_DummyRepo(), 't1') {
    state = const AsyncData(<Post>[]);
  }
}

class _DummyRepo implements ForumRepository {
  bool pinnedCalled = false;
  @override
  Stream<List<Post>> getPostsByThread(String threadId,
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
  Future<void> reportPost(report) async {}
  @override
  Future<void> unvoteOnPost(
          {required String postId, required String userId}) async {}
  @override
  Future<bool> hasVoted(
          {required String postId, required String userId}) async =>
      false;
  @override
  Stream<Thread> watchThread(String threadId) => const Stream.empty();
  @override
  Future<void> setThreadPinned(String threadId, bool pinned) async {
    pinnedCalled = true;
  }

  @override
  Future<void> setThreadLocked(String threadId, bool locked) async {}
}

void main() {
  testWidgets('menu visible only for moderators', (tester) async {
    final thread = Thread(
      id: 't1',
      title: 't1',
      type: ThreadType.general,
      createdBy: 'u1',
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        threadDetailControllerProviderFamily('t1').overrideWith((ref) => _FakeController()),
        threadProviderFamily.overrideWith((ref, id) => Stream.value(thread)),
        isModeratorProvider.overrideWithValue(true),
        forumRepositoryProvider.overrideWithValue(_DummyRepo()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ThreadViewScreen(threadId: 't1'),
      ),
    ));
    await tester.pump();
    expect(find.byType(PopupMenuButton), findsOneWidget);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        threadDetailControllerProviderFamily('t1').overrideWith((ref) => _FakeController()),
        threadProviderFamily.overrideWith((ref, id) => Stream.value(thread)),
        isModeratorProvider.overrideWithValue(false),
        forumRepositoryProvider.overrideWithValue(_DummyRepo()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ThreadViewScreen(threadId: 't1'),
      ),
    ));
    await tester.pump();
    expect(find.byType(PopupMenuButton), findsNothing);
  });

  testWidgets('pin action calls repository', (tester) async {
    final repo = _DummyRepo();
    final thread = Thread(
      id: 't1',
      title: 't1',
      type: ThreadType.general,
      createdBy: 'u1',
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        threadDetailControllerProviderFamily('t1').overrideWith((ref) => _FakeController()),
        threadProviderFamily.overrideWith((ref, id) => Stream.value(thread)),
        isModeratorProvider.overrideWithValue(true),
        forumRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ThreadViewScreen(threadId: 't1'),
      ),
    ));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pin thread'));
    await tester.pumpAndSettle();
    expect(repo.pinnedCalled, isTrue);
  });
}
