import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/providers/composer_controller.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/models/auth_state.dart';
import 'package:tipsterino/models/user.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/routes/app_route.dart';
import 'package:tipsterino/screens/forum/forum_screen.dart';
import 'package:tipsterino/screens/forum/new_thread_screen.dart';

import '../mocks/mock_auth_service.dart';

class _FakeRepo implements ForumRepository {
  @override
  Future<void> addPost(Post post) async {}

  @override
  Future<void> addThread(Thread thread) async {}

  @override
  Future<void> deleteThread(String threadId) async {}

  @override
  Future<void> updatePost({required String threadId, required String postId, required String content}) async {}

  @override
  Future<void> deletePost({required String threadId, required String postId}) async {}

  @override
  Stream<List<Post>> getPostsByThread(String threadId, {int limit = 20, DateTime? startAfter}) => const Stream.empty();

  @override
  Stream<List<Thread>> getRecentThreads({int limit = 20, DateTime? startAfter}) => const Stream.empty();

  @override
  Stream<List<Thread>> getThreadsByFixture(String fixtureId, {int limit = 20, DateTime? startAfter}) => const Stream.empty();

  @override
  Future<void> reportPost(Report report) async {}

  @override
  Future<void> updateThread(String threadId, Map<String, dynamic> data) async {}

  @override
  Future<void> voteOnPost({required String postId, required String userId}) async {}
}

class _FakeComposer extends ComposerController {
  _FakeComposer() : super(_FakeRepo());
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier() : super(MockAuthService()) {
    state = AuthState(user: User(id: 'u1', email: '', displayName: '')); 
  }
}

void main() {
  testWidgets('FAB opens new thread form', (tester) async {
    final router = GoRouter(
      initialLocation: '/forum',
      routes: [
        GoRoute(
          path: '/forum',
          name: AppRoute.forum.name,
          builder: (context, state) => const ForumScreen(),
          routes: [
            GoRoute(
              path: 'new',
              name: AppRoute.newThread.name,
              builder: (context, state) => const NewThreadScreen(),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          composerControllerProvider.overrideWith((ref) => _FakeComposer()),
          authProvider.overrideWith((ref) => _FakeAuthNotifier()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(NewThreadScreen), findsOneWidget);
  });
}
