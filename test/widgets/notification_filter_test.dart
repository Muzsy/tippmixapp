import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/notification_model.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tippmixapp/services/analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/providers/notification_provider.dart';
import 'package:tippmixapp/screens/notification_center/notification_center_v2.dart';
import 'package:tippmixapp/services/notification_service.dart';

class FakeAuthService implements AuthService {
  @override
  Stream<User?> authStateChanges() => const Stream.empty();
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
  bool get isEmailVerified => true;
  @override
  User? get currentUser => null;
  Future<bool> validateEmailUnique(String email) async => true;
  Future<bool> validateNicknameUnique(String nickname) async => true;

  @override
  Future<User?> signInWithGoogle() async => null;

  @override
  Future<User?> signInWithApple() async => null;

  @override
  Future<User?> signInWithFacebook() async => null;
  @override
  Future<bool> pollEmailVerification({Duration timeout = const Duration(minutes: 3), Duration interval = const Duration(seconds: 5),}) async => true;
  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {}
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier() : super(FakeAuthService()) {
    state = AuthState(
      user: User(id: 'u1', email: '', displayName: ''),
    );
  }
}

// ignore: subtype_of_sealed_class
class FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  @override
  final String id;
  final Map<String, Map<String, dynamic>> store;
  FakeDocumentReference(this.id, this.store);

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    store[id] = data;
  }

  @override
  Future<void> update(Map<Object, Object?> data) async {
    final current = store[id] ?? <String, dynamic>{};
    data.forEach((key, value) {
      if (key is String) {
        current[key] = value;
      }
    });
    store[id] = current;
  }
}

// ignore: subtype_of_sealed_class
class FakeCollectionReference extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  final Map<String, Map<String, dynamic>> store;
  FakeCollectionReference(this.store);

  @override
  DocumentReference<Map<String, dynamic>> doc([String? id]) {
    final key = id ?? 'doc${store.length}';
    store.putIfAbsent(key, () => <String, dynamic>{});
    return FakeDocumentReference(key, store);
  }
}

// ignore: subtype_of_sealed_class
class FakeFirebaseFirestore extends Fake implements FirebaseFirestore {
  final Map<String, Map<String, Map<String, dynamic>>> data = {};

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    data.putIfAbsent(path, () => <String, Map<String, dynamic>>{});
    return FakeCollectionReference(data[path]!);
  }
}

class FakeFirebaseAnalytics extends Fake implements FirebaseAnalytics {}

class FakeAnalyticsService extends AnalyticsService {
  FakeAnalyticsService() : super(FakeFirebaseAnalytics());
  @override
  Future<void> logNotificationOpened(String category) async {}
}

class FakeNotificationService extends NotificationService {
  int archiveCalls = 0;
  FakeNotificationService() : super(FakeFirebaseFirestore());

  @override
  Future<void> archive(String userId, String notificationId) async {
    archiveCalls++;
  }

  @override
  Stream<List<NotificationModel>> streamNotifications(String userId) =>
      const Stream.empty();
}

void main() {
  testWidgets('filters by category and archives', (tester) async {
    final controller = StreamController<List<NotificationModel>>();
    final service = FakeNotificationService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationStreamProvider.overrideWith((ref) => controller.stream),
          notificationServiceProvider.overrideWithValue(service),
          authProvider.overrideWith((ref) => FakeAuthNotifier()),
          analyticsServiceProvider.overrideWith(
            (ref) => FakeAnalyticsService(),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: NotificationCenterScreenV2(),
        ),
      ),
    );

    controller.add([
      NotificationModel(
        id: 'n1',
        type: NotificationType.reward,
        title: 'Reward',
        description: 'd',
        timestamp: DateTime.now(),
        category: NotificationCategory.rewards,
      ),
      NotificationModel(
        id: 'n2',
        type: NotificationType.friend,
        title: 'Social',
        description: 'd',
        timestamp: DateTime.now(),
        category: NotificationCategory.social,
      ),
    ]);

    await tester.pump();
    await tester.tap(find.text('Social'));
    await tester.pump();
    expect(find.text('Social'), findsWidgets);

    await tester.drag(find.text('Social').first, const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(service.archiveCalls, 1);
  });
}
