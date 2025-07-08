import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'package:tippmixapp/widgets/follow_button.dart';
import 'package:tippmixapp/providers/social_provider.dart';
import 'package:tippmixapp/services/social_service.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/models/user.dart' as tm;
import 'package:tippmixapp/services/auth_service.dart';
import 'package:tippmixapp/providers/auth_provider.dart'
    show AuthNotifier, authProvider;

class FakeSocialService extends Fake implements SocialService {
  bool followCalled = false;
  @override
  Future<void> followUser(String targetUid) async {
    followCalled = true;
  }

  @override
  Future<void> unfollowUser(String targetUid) async {}
}

class FakeAuthService implements AuthService {
  final _controller = StreamController<tm.User?>.broadcast();
  tm.User? _current;

  @override
  Stream<tm.User?> authStateChanges() => _controller.stream;

  @override
  Future<tm.User?> signInWithEmail(String email, String password) async => null;

  @override
  Future<tm.User?> registerWithEmail(String email, String password) async =>
      null;

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  bool get isEmailVerified => true;

  @override
  tm.User? get currentUser => _current;
  @override
  Future<bool> validateEmailUnique(String email) async => true;
  @override
  Future<bool> validateNicknameUnique(String nickname) async => true;

  @override
  Future<tm.User?> signInWithGoogle() async => null;

  @override
  Future<tm.User?> signInWithApple() async => null;

  @override
  Future<tm.User?> signInWithFacebook() async => null;
  @override
  Future<bool> pollEmailVerification({Duration timeout = const Duration(minutes: 3), Duration interval = const Duration(seconds: 5),}) async => true;
  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {}
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(tm.User user) : super(FakeAuthService()) {
    state = AuthState(user: user);
  }
}

void main() {
  testWidgets('tapping follow triggers service', (tester) async {
    final service = FakeSocialService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          socialServiceProvider.overrideWithValue(service),
          followersProvider.overrideWith((ref, uid) => Stream.value([])),
          authProvider.overrideWith(
            (ref) =>
                FakeAuthNotifier(tm.User(id: 'me', email: '', displayName: '')),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FollowButton(targetUid: 'u2'),
        ),
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pump();

    expect(service.followCalled, isTrue);
  });
}
