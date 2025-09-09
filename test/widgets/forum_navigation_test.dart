import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/providers/forum_filter_state.dart';
import 'package:tipsterino/features/forum/providers/thread_list_controller.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/routes/app_route.dart';
import 'package:tipsterino/screens/forum/forum_screen.dart';

class _FakeRepo implements ForumRepository {
  @override
  Stream<List<Thread>> queryThreads({required ForumFilter filter, required ForumSort sort, int limit = 20, DateTime? startAfter}) => const Stream.empty();
  @override
  Stream<List<Thread>> getPostsByThread(String threadId, {int limit = 20, DateTime? startAfter}) => const Stream.empty();
  @override
  Stream<List<Thread>> getThreadsByFixture(String fixtureId, {int limit = 20, DateTime? startAfter}) => const Stream.empty();
  @override
  Future<void> addThread(Thread thread) async {}
  @override
  Future<void> updateThread(String threadId, Map<String, dynamic> data) async {}
  @override
  Future<void> deleteThread(String threadId) async {}
  @override
  Future<void> addPost(post) async {}
  @override
  Future<void> updatePost({required String threadId, required String postId, required String content}) async {}
  @override
  Future<void> deletePost({required String threadId, required String postId}) async {}
  @override
  Future<void> voteOnPost({required String postId, required String userId}) async {}
  @override
  Future<void> reportPost(report) async {}
}

class _FakeController extends ThreadListController {
  _FakeController(List<Thread> threads)
      : super(_FakeRepo(), const ForumFilterState()) {
    state = AsyncData(threads);
  }
}

void main() {
  testWidgets('taps thread navigates to view', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ForumScreen(),
          routes: [
            GoRoute(
              path: ':threadId',
              name: AppRoute.threadView.name,
              builder: (context, state) => Text('Thread ${state.pathParameters['threadId']}'),
            ),
          ],
        ),
      ],
    );
    final thread = Thread(
      id: 't1',
      title: 'T1',
      type: ThreadType.general,
      createdBy: 'u1',
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        threadListControllerProvider.overrideWith((ref) => _FakeController([thread])),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    await tester.pump();
    await tester.tap(find.text('T1'));
    await tester.pumpAndSettle();
    expect(find.text('Thread t1'), findsOneWidget);
  });
}
