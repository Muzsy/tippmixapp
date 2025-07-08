import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  bool get isEmailVerified => true;

  @override
  User? get currentUser => _current;
  Future<bool> validateEmailUnique(String email) async => true;
  Future<bool> validateNicknameUnique(String nickname) async => true;

  @override
  Future<User?> signInWithGoogle() async => null;

  @override
  Future<User?> signInWithApple() async => null;

  @override
  Future<User?> signInWithFacebook() async => null;
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(User? user) : super(FakeAuthService()) {
    state = AuthState(user: user);
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

class FakeNotificationService extends NotificationService {
  int markCalls = 0;
  FakeNotificationService() : super(FakeFirebaseFirestore());

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    markCalls++;
  }
}

Future<void> _pumpApp(
  WidgetTester tester,
  Stream<List<NotificationModel>> stream, {
  Locale locale = const Locale('en'),
  required FakeNotificationService service,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        notificationStreamProvider.overrideWith((ref) => stream),
        notificationServiceProvider.overrideWithValue(service),
        authProvider.overrideWith(
          (ref) =>
              FakeAuthNotifier(User(id: 'u1', email: '', displayName: 'Me')),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: const NotificationCenterScreen(),
      ),
    ),
  );
}

void main() {
  group('NotificationCenterScreen', () {
    late StreamController<List<NotificationModel>> controller;
    late FakeNotificationService service;

    setUp(() {
      controller = StreamController<List<NotificationModel>>();
      service = FakeNotificationService();
    });

    tearDown(() {
      controller.close();
    });

    testWidgets('NC-01 list is ordered by timestamp descending', (
      tester,
    ) async {
      await _pumpApp(tester, controller.stream, service: service);
      final n1 = NotificationModel(
        id: 'n1',
        type: NotificationType.reward,
        title: 't1',
        description: 'd',
        timestamp: DateTime(2020),
      );
      final n2 = NotificationModel(
        id: 'n2',
        type: NotificationType.reward,
        title: 't2',
        description: 'd',
        timestamp: DateTime(2021),
      );
      final n3 = NotificationModel(
        id: 'n3',
        type: NotificationType.reward,
        title: 't3',
        description: 'd',
        timestamp: DateTime(2022),
      );
      controller.add([n1, n2, n3]);
      await tester.pump();
      final firstPos = tester.getTopLeft(find.text('t3')).dy;
      final secondPos = tester.getTopLeft(find.text('t2')).dy;
      expect(firstPos < secondPos, isTrue);
    });

    testWidgets('NC-02 shows unread indicator', (tester) async {
      await _pumpApp(tester, controller.stream, service: service);
      final n = NotificationModel(
        id: 'n1',
        type: NotificationType.reward,
        title: 'unread',
        description: 'd',
        timestamp: DateTime.now(),
      );
      controller.add([n]);
      await tester.pump();
      expect(find.text('Mark read'), findsOneWidget);
    });

    testWidgets('NC-03 mark notification read on tap', (tester) async {
      await _pumpApp(tester, controller.stream, service: service);
      final n = NotificationModel(
        id: 'n1',
        type: NotificationType.reward,
        title: 'tap',
        description: 'd',
        timestamp: DateTime.now(),
      );
      controller.add([n]);
      await tester.pump();
      await tester.tap(find.text('tap'));
      await tester.pumpAndSettle();
      expect(service.markCalls, 1);
    });

    testWidgets('NC-04 filter unread shows only unread items', (tester) async {
      await _pumpApp(tester, controller.stream, service: service);
      final read = NotificationModel(
        id: 'n1',
        type: NotificationType.reward,
        title: 'read',
        description: 'd',
        timestamp: DateTime.now(),
        isRead: true,
      );
      final unread = NotificationModel(
        id: 'n2',
        type: NotificationType.reward,
        title: 'unread',
        description: 'd',
        timestamp: DateTime.now(),
      );
      controller.add([read, unread]);
      await tester.pump();
      await tester.tap(find.text('Unread'));
      await tester.pumpAndSettle();
      expect(find.text('unread'), findsOneWidget);
      expect(find.text('read'), findsNothing);
    });

    testWidgets('NC-05 push stream inserts newest item on top', (tester) async {
      await _pumpApp(tester, controller.stream, service: service);
      final old = NotificationModel(
        id: 'n1',
        type: NotificationType.reward,
        title: 'old',
        description: 'd',
        timestamp: DateTime(2020),
      );
      controller.add([old]);
      await tester.pump();
      final newest = NotificationModel(
        id: 'n2',
        type: NotificationType.reward,
        title: 'new',
        description: 'd',
        timestamp: DateTime(2021),
      );
      controller.add([newest, old]);
      await tester.pump();
      final firstPos = tester.getTopLeft(find.text('new')).dy;
      final secondPos = tester.getTopLeft(find.text('old')).dy;
      expect(firstPos < secondPos, isTrue);
    });

    testWidgets('NC-06 pull to refresh reloads provider', (tester) async {
      await _pumpApp(tester, controller.stream, service: service);
      final n = NotificationModel(
        id: 'n1',
        type: NotificationType.reward,
        title: 'item',
        description: 'd',
        timestamp: DateTime.now(),
      );
      controller.add([n]);
      await tester.pump();
      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pumpAndSettle();
      expect(find.text('item'), findsOneWidget);
    });

    testWidgets('NC-07 empty state message', (tester) async {
      await _pumpApp(tester, controller.stream, service: service);
      controller.add([]);
      await tester.pump();
      expect(find.text('No new notifications'), findsOneWidget);
    });

    testWidgets('NC-08 localization HU', (tester) async {
      await _pumpApp(
        tester,
        controller.stream,
        service: service,
        locale: const Locale('hu'),
      );
      controller.add([]);
      await tester.pump();
      expect(find.text('Nincs új esemény'), findsOneWidget);
    });

    testWidgets('NC-09 localization DE', (tester) async {
      await _pumpApp(
        tester,
        controller.stream,
        service: service,
        locale: const Locale('de'),
      );
      controller.add([]);
      await tester.pump();
      expect(find.text('Keine neuen Ereignisse'), findsOneWidget);
    });

    testWidgets('NC-10 shows error snackbar on failure', (tester) async {
      await _pumpApp(tester, controller.stream, service: service);
      controller.addError('boom');
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('NC-11 long list scrolls without overflow', (tester) async {
      await _pumpApp(tester, controller.stream, service: service);
      controller.add(
        List.generate(
          200,
          (i) => NotificationModel(
            id: 'n$i',
            type: NotificationType.reward,
            title: 't$i',
            description: 'd',
            timestamp: DateTime.now(),
          ),
        ),
      );
      await tester.pump();
      await tester.fling(find.byType(ListView), const Offset(0, -1000), 1000);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
