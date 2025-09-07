import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/features/forum/providers/composer_controller.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/l10n/app_localizations_en.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/screens/forum/new_thread_screen.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/models/auth_state.dart';
import 'package:tipsterino/models/user.dart';

import '../mocks/mock_auth_service.dart';

class _FakeRepo implements ForumRepository {
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

class _FakeComposer extends ComposerController {
  _FakeComposer() : super(_FakeRepo());
  bool called = false;

  @override
  Future<void> createThread(Thread thread, Post firstPost) async {
    called = true;
  }
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier()
      : super(MockAuthService()) {
    state = AuthState(user: User(id: 'u1', email: 'e', displayName: 'Me'));
  }
}

Widget _buildApp(_FakeComposer composer) {
  return ProviderScope(
    overrides: [
      composerControllerProvider.overrideWith((ref) => composer),
      authProvider.overrideWith((ref) => _FakeAuthNotifier()),
    ],
    child: MaterialApp(
      home: const NewThreadScreen(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  testWidgets('button disabled when fields empty', (tester) async {
    final composer = _FakeComposer();
    await tester.pumpWidget(_buildApp(composer));
    final btn = tester.widget<ElevatedButton>(find.byKey(const Key('submit')));
    expect(btn.onPressed, isNull);
  });

  testWidgets('creates thread when valid', (tester) async {
    final composer = _FakeComposer();
    await tester.pumpWidget(_buildApp(composer));
    await tester.enterText(find.byKey(const Key('title')), 'Hello');
    await tester.enterText(find.byKey(const Key('content')), 'First post');
    await tester.pump();
    await tester.tap(find.text(AppLocalizationsEn().btn_create_thread));
    await tester.pump();
    expect(composer.called, isTrue);
  });
}
