import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/screens/forum/thread_view_screen.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/features/forum/providers/thread_detail_controller.dart';

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
  Stream<List<Thread>> getRecentThreads({int limit = 20, DateTime? startAfter}) =>
      const Stream.empty();

  @override
  Stream<List<Thread>> getThreadsByFixture(String fixtureId,
          {int limit = 20, DateTime? startAfter}) =>
      const Stream.empty();

  @override
  Future<void> reportPost(Report report) async {}

  @override
  Future<void> updateThread(String threadId, Map<String, dynamic> data) async {}

  @override
  Future<void> voteOnPost({required String postId, required String userId}) async {}
}

class _FakeController extends ThreadDetailController {
  _FakeController(AsyncValue<List<Post>> state)
      : super(_DummyRepo(), 't1') {
    this.state = state;
  }

  @override
  void dispose() {}
}

void main() {
  testWidgets('shows empty state when no posts', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          threadDetailControllerProviderFamily('t1').overrideWith(
            (ref) => _FakeController(const AsyncValue.data([])),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ThreadViewScreen(threadId: 't1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No threads yet'), findsOneWidget);
  });
}
