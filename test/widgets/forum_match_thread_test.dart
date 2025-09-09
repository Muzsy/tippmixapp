import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tipsterino/features/forum/providers/composer_controller.dart';
import 'package:tipsterino/screens/forum/new_thread_screen.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/l10n/app_localizations_en.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/models/auth_state.dart';
import 'package:tipsterino/models/user.dart';
import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import '../mocks/mock_auth_service.dart';

class _FakeRepo implements ForumRepository {
  @override
  Future<void> addThread(Thread thread) async {}
  @override
  Future<void> addPost(Post post) async {}
  @override
  Future<void> updateThread(String threadId, Map<String, dynamic> data) async {}
  @override
  Future<void> deleteThread(String threadId) async {}
  @override
  Stream<List<Thread>> queryThreads({required ForumFilter filter, required ForumSort sort, int limit = 20, DateTime? startAfter}) => const Stream.empty();
  @override
  Stream<List<Post>> getPostsByThread(String threadId, {int limit = 20, DateTime? startAfter}) => const Stream.empty();
  @override
  Stream<List<Thread>> getThreadsByFixture(String fixtureId, {int limit = 20, DateTime? startAfter}) => const Stream.empty();
  @override
  Future<void> updatePost({required String threadId, required String postId, required String content}) async {}
  @override
  Future<void> deletePost({required String threadId, required String postId}) async {}
  @override
  Future<void> voteOnPost({required String postId, required String userId}) async {}
  @override
  Future<void> reportPost(Report report) async {}
}

class _Composer extends ComposerController {
  _Composer() : super(_FakeRepo());
}

class _Auth extends AuthNotifier {
  _Auth() : super(MockAuthService()) {
    state = AuthState(user: User(id: 'u1', email: 'e', displayName: 'u'));
  }
}

void main() {
  testWidgets('requires fixture when match type selected', (tester) async {
    final composer = _Composer();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        composerControllerProvider.overrideWith((ref) => composer),
        authProvider.overrideWith((ref) => _Auth()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const NewThreadScreen(),
      ),
    ));
    await tester.tap(find.byType(DropdownButtonFormField<ThreadType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLocalizationsEn().thread_type_match).last);
    await tester.pump();
    expect(find.byKey(const Key('fixture')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('title')), 't');
    await tester.enterText(find.byKey(const Key('content')), 'c');
    await tester.enterText(find.byKey(const Key('fixture')), '1');
    await tester.pump();
    final btn = tester.widget<ElevatedButton>(find.byKey(const Key('submit')));
    expect(btn.onPressed, isNotNull);
  });
}
