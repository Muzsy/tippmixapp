import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/providers/thread_detail_controller.dart';
import 'package:tipsterino/models/auth_state.dart';
import 'package:tipsterino/models/user.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/screens/forum/post_item.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

class _DummyRepo implements ForumRepository {
  @override
  Future<void> addPost(Post post) async {}

  @override
  Future<void> addThread(Thread thread) async {}

  @override
  Future<void> deletePost({required String threadId, required String postId}) async {}

  @override
  Future<void> deleteThread(String threadId) async {}

  @override
  Stream<List<Post>> getPostsByThread(String threadId, {int limit = 20, DateTime? startAfter}) => const Stream.empty();

  @override
  Stream<List<Thread>> getRecentThreads({int limit = 20, DateTime? startAfter}) => const Stream.empty();

  @override
  Stream<List<Thread>> getThreadsByFixture(String fixtureId, {int limit = 20, DateTime? startAfter}) => const Stream.empty();

  @override
  Future<void> reportPost(Report report) async {}

  @override
  Future<void> updatePost({required String threadId, required String postId, required String content}) async {}

  @override
  Future<void> updateThread(String threadId, Map<String, dynamic> data) async {}

  @override
  Future<void> voteOnPost({required String postId, required String userId}) async {}
}

class _FakeAuth extends StateNotifier<AuthState> {
  _FakeAuth() : super(AuthState(user: User(id: 'u1', email: '', displayName: '')));
}

class _TestController extends ThreadDetailController {
  _TestController() : super(_DummyRepo(), 't1');

  bool addCalled = false;
  bool updateCalled = false;
  bool deleteCalled = false;
  bool voteCalled = false;
  bool reportCalled = false;

  @override
  Future<void> addPost(Post post) async {
    addCalled = true;
  }

  @override
  Future<void> updatePost(String postId, String content) async {
    updateCalled = true;
  }

  @override
  Future<void> deletePost(String postId) async {
    deleteCalled = true;
  }

  @override
  Future<void> voteOnPost(String postId, String userId) async {
    voteCalled = true;
  }

  @override
  Future<void> reportPost(Report report) async {
    reportCalled = true;
  }
}

class _FailVoteController extends _TestController {
  @override
  Future<void> voteOnPost(String postId, String userId) async {
    throw Exception('fail');
  }
}

void main() {
  final post = Post(
    id: 'p1',
    threadId: 't1',
    userId: 'u1',
    type: PostType.comment,
    content: 'hello',
    createdAt: DateTime(2024),
  );

  testWidgets('buttons call controller methods', (tester) async {
    final controller = _TestController();
    var replied = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => _FakeAuth()),
          threadDetailControllerProviderFamily('t1').overrideWith((ref) => controller),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PostItem(
            post: post,
            onReply: () => replied = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.reply));
    expect(replied, isTrue);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'edited');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(controller.updateCalled, isTrue);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    expect(controller.deleteCalled, isTrue);

    await tester.tap(find.byIcon(Icons.thumb_up));
    await tester.pumpAndSettle();
    expect(controller.voteCalled, isTrue);

    await tester.tap(find.byIcon(Icons.flag));
    await tester.pumpAndSettle();
    expect(controller.reportCalled, isTrue);
  });

  testWidgets('vote failure shows error and reverts state', (tester) async {
    final controller = _FailVoteController();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => _FakeAuth()),
          threadDetailControllerProviderFamily('t1').overrideWith((ref) => controller),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PostItem(post: post),
        ),
      ),
    );

    final initialColor = tester.widget<Icon>(find.byIcon(Icons.thumb_up)).color;
    await tester.tap(find.byIcon(Icons.thumb_up));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final afterColor = tester.widget<Icon>(find.byIcon(Icons.thumb_up)).color;
    expect(afterColor, initialColor);
    expect(find.text('Unknown error, please try again'), findsOneWidget);
  });
}
