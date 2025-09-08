import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/providers/forum_filter_state.dart';
import 'package:tipsterino/features/forum/providers/thread_detail_controller.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/l10n/app_localizations_en.dart';
import 'package:tipsterino/models/auth_state.dart';
import 'package:tipsterino/models/user.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/screens/forum/post_item.dart';
import 'package:tipsterino/services/auth_service.dart';

class _DummyRepo implements ForumRepository {
  Report? lastReport;

  @override
  Stream<List<Post>> getPostsByThread(
    String threadId, {
    int limit = 20,
    DateTime? startAfter,
  }) => const Stream.empty();

  @override
  Future<void> reportPost(Report report) async {
    lastReport = report;
  }

  @override
  Future<void> addPost(Post post) async {}

  @override
  Future<void> addThread(Thread thread) async {}

  @override
  Future<void> deletePost({required String threadId, required String postId}) async {}

  @override
  Future<void> deleteThread(String threadId) async {}

  @override
  Stream<List<Thread>> getThreadsByFixture(String fixtureId,
          {int limit = 20, DateTime? startAfter}) =>
      const Stream.empty();

  @override
  Stream<List<Thread>> queryThreads({
    required ForumFilter filter,
    required ForumSort sort,
    int limit = 20,
    DateTime? startAfter,
  }) => const Stream.empty();

  @override
  Future<void> updatePost({
    required String threadId,
    required String postId,
    required String content,
  }) async {}

  @override
  Future<void> updateThread(String threadId, Map<String, dynamic> data) async {}

  @override
  Future<void> voteOnPost({required String postId, required String userId}) async {}
}

class _FakeController extends ThreadDetailController {
  _FakeController(this.repo) : super(repo, 't1');
  final _DummyRepo repo;

  @override
  Future<void> reportPost(Report report) async {
    await repo.reportPost(report);
  }

  Report? get lastReport => repo.lastReport;
}

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

class _AuthNotifier extends AuthNotifier {
  _AuthNotifier() : super(_StubAuthService()) {
    state = AuthState(user: User(id: 'u1', email: '', displayName: ''));
  }
}

void main() {
  testWidgets('submits report with reason and note', (tester) async {
    final repo = _DummyRepo();
    final controller = _FakeController(repo);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => _AuthNotifier()),
          threadDetailControllerProviderFamily('t1')
              .overrideWith((ref) => controller),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PostItem(
              post: Post(
                id: 'p1',
                threadId: 't1',
                userId: 'u2',
                type: PostType.tip,
                content: 'hi',
                createdAt: DateTime.now(),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip(AppLocalizationsEn().feed_report));
    await tester.pumpAndSettle();
    expect(find.text(AppLocalizationsEn().report_dialog_title), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'note');
    await tester.tap(find.text(AppLocalizationsEn().dialog_send));
    await tester.pumpAndSettle();

    expect(controller.lastReport?.reason, 'spam');
    expect(controller.lastReport?.message, 'note');
  });
}
