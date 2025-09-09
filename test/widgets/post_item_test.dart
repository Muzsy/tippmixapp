import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/providers/thread_detail_controller.dart';
import 'package:tipsterino/models/user.dart';
import 'package:tipsterino/models/auth_state.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/screens/forum/post_item.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

import 'package:tipsterino/services/auth_service.dart';
import '../mocks/fake_forum_repository.dart';
class _StubAuthService implements AuthService {
  @override
  Stream<User?> authStateChanges() async* {}
  @override
  Future<User?> signInWithEmail(String email, String password) async => null;
  @override
  Future<User?> registerWithEmail(String email, String password) async => null;
  @override
  Future<void> signOut() async {}
  @override
  Future<void> sendEmailVerification() async {}
  @override
  Future<void> sendPasswordResetEmail(String email) async {}
  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {}
  @override
  bool get isEmailVerified => true;
  @override
  User? get currentUser => null;
  @override
  Future<bool> validateEmailUnique(String email) async => true;
  @override
  Future<bool> validateNicknameUnique(String nickname) async => true;
  @override
  Future<User?> signInWithGoogle() async => null;
  @override
  Future<User?> signInWithApple() async => null;
  @override
  Future<User?> signInWithFacebook() async => null;
  @override
  Future<bool> pollEmailVerification({
    Duration timeout = const Duration(minutes: 3),
    Duration interval = const Duration(seconds: 5),
  }) async => true;
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(User user) : super(_StubAuthService()) {
    state = AuthState(user: user);
  }
}

class TestForumRepository extends FakeForumRepository {
  bool voteCalled = false;

  @override
  Future<void> voteOnPost({required String postId, required String userId}) async {
    voteCalled = true;
  }
}

void main() {
  testWidgets('upvote calls repository', (tester) async {
    final repo = TestForumRepository();
    final post = Post(
      id: 'p1',
      threadId: 't1',
      userId: 'u1',
      type: PostType.comment,
      content: 'Hello',
      createdAt: DateTime.now(),
    );
    final user = User(id: 'u1', email: '', displayName: '');
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) => FakeAuthNotifier(user)),
        threadDetailControllerProviderFamily('t1')
            .overrideWith((ref) => ThreadDetailController(repo, 't1')),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: PostItem(post: post)),
      ),
    ));

    // Tap the like button by its localized tooltip to avoid icon-set differences.
    await tester.tap(find.byTooltip('Like'));
    await tester.pump();

    expect(repo.voteCalled, true);
  });
}
