import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/providers/thread_detail_controller.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/screens/forum/thread_view_screen.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

class _FakeController extends ThreadDetailController {
  _FakeController() : super(_DummyRepo(), 't1') {
    state = const AsyncData(<Post>[]);
  }
}

class _DummyRepo implements ForumRepository {
  @override
  Stream<List<Post>> getPostsByThread(String threadId, {int limit = 20, DateTime? startAfter}) => const Stream.empty();
  @override
  Stream<List<Thread>> queryThreads({required ForumFilter filter, required ForumSort sort, int limit = 20, DateTime? startAfter}) => const Stream.empty();
  @override
  Stream<List<Thread>> getThreadsByFixture(String fixtureId, {int limit = 20, DateTime? startAfter}) => const Stream.empty();
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
  Future<void> reportPost(report) async {}
  @override
  Future<void> unvoteOnPost({required String postId, required String userId}) async {}
  @override
  Future<bool> hasVoted({required String postId, required String userId}) async => false;
  @override
  Stream<Thread> watchThread(String threadId) => Stream.value(Thread(
        id: 't1',
        title: 't1',
        type: ThreadType.general,
        createdBy: 'u1',
        createdAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
        locked: true,
      ));
}

void main() {
  testWidgets('composer disabled when locked', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        threadDetailControllerProviderFamily('t1').overrideWith((ref) => _FakeController()),
        threadProviderFamily.overrideWith((ref, id) => Stream.value(Thread(
              id: 't1',
              title: 't1',
              type: ThreadType.general,
              createdBy: 'u1',
              createdAt: DateTime.now(),
              lastActivityAt: DateTime.now(),
              locked: true,
            ))),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ThreadViewScreen(threadId: 't1'),
      ),
    ));
    await tester.pump();
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enabled, isFalse);
  });
}
