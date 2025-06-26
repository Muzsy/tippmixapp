import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/notification_model.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/providers/notification_provider.dart';
import 'package:tippmixapp/screens/notifications/notification_center_screen.dart';
import 'package:tippmixapp/services/auth_service.dart';
import 'package:tippmixapp/services/notification_service.dart';

class FakeAuthService implements AuthService {
  final _controller = StreamController<User?>.broadcast();
  User? _current;

  @override
  Stream<User?> authStateChanges() => _controller.stream;

  @override
  Future<User?> signInWithEmail(String email, String password) async => null;

  @override
  Future<User?> registerWithEmail(String email, String password) async => null;

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }

  @override
  User? get currentUser => _current;
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(User? user) : super(FakeAuthService()) {
    state = AuthState(user: user);
  }
}

class FakeNotificationService extends NotificationService {
  int markCalls = 0;
  FakeNotificationService() : super(null);

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    markCalls++;
  }
}

void main() {
  testWidgets('displays notifications and mark as read', (tester) async {
    final controller = StreamController<List<NotificationModel>>();
    final service = FakeNotificationService();
    final notification = NotificationModel(
      id: 'n1',
      type: NotificationType.reward,
      title: 'Reward',
      description: 'desc',
      timestamp: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationStreamProvider.overrideWith((ref) => controller.stream),
          notificationServiceProvider.overrideWithValue(service),
          authProvider.overrideWith((ref) => FakeAuthNotifier(User(id: 'u1', email: '', displayName: 'Me'))),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: NotificationCenterScreen(),
        ),
      ),
    );

    controller.add([notification]);
    await tester.pump();

    expect(find.text('Reward'), findsOneWidget);
    await tester.tap(find.text('Reward'));
    await tester.pumpAndSettle();
    expect(service.markCalls, 1);
  });
}
