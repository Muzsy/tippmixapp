import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/providers/thread_detail_controller.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/models/auth_state.dart';
import 'package:tipsterino/models/user.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/screens/forum/post_item.dart';
import 'package:tipsterino/services/auth_service.dart';
import '../mocks/fake_forum_repository.dart';

class _Repo extends FakeForumRepository {
  bool voted = false;
  bool unvoted = false;
  @override
  Future<void> voteOnPost({required String postId, required String userId}) async {
    voted = true;
  }

  @override
  Future<void> unvoteOnPost({required String postId, required String userId}) async {
    unvoted = true;
  }

  @override
  Future<bool> hasVoted({required String postId, required String userId}) async => false;

}

class _Auth extends AuthNotifier {
  _Auth() : super(_Mock()) {
    state = AuthState(user: User(id: 'u1', email: 'e', displayName: 'd'));
  }
}

class _Mock implements AuthService {
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
  Future<bool> pollEmailVerification({Duration timeout = const Duration(), Duration interval = const Duration()}) async => true;
}

void main() {
  testWidgets('toggling vote calls repo', (tester) async {
    final repo = _Repo();
    final post = Post(
      id: 'p1',
      threadId: 't1',
      userId: 'u2',
      type: PostType.comment,
      content: 'c',
      createdAt: DateTime.now(),
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) => _Auth()),
        threadDetailControllerProviderFamily('t1').overrideWith((ref) => ThreadDetailController(repo, 't1')),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: PostItem(post: post)),
      ),
    ));
    await tester.tap(find.byTooltip('Like'));
    await tester.pump();
    await tester.tap(find.byTooltip('Like'));
    await tester.pump();
    expect(repo.voted, isTrue);
    expect(repo.unvoted, isTrue);
  });
}
