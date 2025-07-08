import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/feed_event_type.dart';
import 'package:tippmixapp/models/feed_model.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/models/tip_model.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/providers/feed_provider.dart';
import 'package:tippmixapp/widgets/home_feed.dart';
import 'package:tippmixapp/widgets/components/comment_modal.dart';
import 'package:tippmixapp/widgets/components/report_dialog.dart';
import 'package:tippmixapp/services/auth_service.dart';
import 'package:tippmixapp/flows/copy_bet_flow.dart';
import 'package:tippmixapp/services/feed_service.dart';

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(User? user) : super(FakeAuthService()) {
    state = AuthState(user: user);
  }
}

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
// Remove the local FeedService definition and just implement the imported one.

class FakeFeedService implements FeedService {
  int likeCalls = 0;
  final FirebaseFirestore firestore;

  FakeFeedService() : firestore = FakeFirebaseFirestore();

  @override
  Future<void> addFeedEntry({
    required String userId,
    required FeedEventType eventType,
    required String message,
    Map<String, dynamic>? extraData,
  }) async {
    likeCalls++;
  }

  @override
  Stream<List<FeedModel>> streamFeed() => const Stream.empty();

  @override
  Future<void> reportFeedItem({
    required String userId,
    required String targetId,
    required String targetType,
    required String reason,
  }) async {}

  @override
  Future<FeedModel?> fetchLatestEntry() async => null;

  // Add any other members or methods required by FeedService interface here.
}

void main() {
  testWidgets('HomeFeedWidget shimmer and empty state', (tester) async {
    final controller = StreamController<List<FeedModel>>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          feedStreamProvider.overrideWith((ref) => controller.stream),
          authProvider.overrideWith((ref) => FakeAuthNotifier(null)),
          copyTicketProvider.overrideWithValue(
            ({
              required String userId,
              required String ticketId,
              required List<TipModel> tips,
              String? sourceUserId,
              FirebaseFirestore? firestore,
            }) async => 'id',
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(body: HomeFeedWidget()),
        ),
      ),
    );

    expect(find.byKey(const Key('shimmer')), findsWidgets);

    controller.add([]);
    await tester.pump();
    expect(find.text('No posts yet'), findsOneWidget);
  });

  testWidgets('Like disabled for own post and dialogs show', (tester) async {
    final controller = StreamController<List<FeedModel>>();
    final item = FeedModel(
      userId: 'u1',
      eventType: FeedEventType.comment,
      message: 'msg',
      timestamp: DateTime.now(),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          feedStreamProvider.overrideWith((ref) => controller.stream),
          authProvider.overrideWith(
            (ref) =>
                FakeAuthNotifier(User(id: 'u1', email: '', displayName: 'me')),
          ),
          copyTicketProvider.overrideWithValue(
            ({
              required String userId,
              required String ticketId,
              required List<TipModel> tips,
              String? sourceUserId,
              FirebaseFirestore? firestore,
            }) async => 'id',
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(body: HomeFeedWidget()),
        ),
      ),
    );

    controller.add([item]);
    await tester.pump();

    final likeButtonFinder = find.widgetWithIcon(IconButton, Icons.thumb_up);
    expect(likeButtonFinder, findsOneWidget);
    final likeButton = tester.widget<IconButton>(likeButtonFinder);
    expect(likeButton.onPressed, isNull);

    final commentFinder = find.widgetWithIcon(IconButton, Icons.comment);
    expect(commentFinder, findsOneWidget);
    await tester.tap(commentFinder);
    await tester.pumpAndSettle();
    expect(find.byType(CommentModal), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final reportFinder = find.widgetWithIcon(IconButton, Icons.report);
    expect(reportFinder, findsOneWidget);
    await tester.tap(reportFinder);
    await tester.pumpAndSettle();
    expect(find.byType(ReportDialog), findsOneWidget);
  });

  testWidgets('Like and copy actions trigger services', (tester) async {
    final controller = StreamController<List<FeedModel>>();
    final feedService = FakeFeedService();
    var copyCalled = false;
    final item = FeedModel(
      userId: 'u2',
      eventType: FeedEventType.betPlaced,
      message: 'bet',
      timestamp: DateTime.now(),
      extraData: {'ticketId': 't1', 'tips': <Map<String, dynamic>>[]},
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          feedStreamProvider.overrideWith((ref) => controller.stream),
          feedServiceProvider.overrideWithValue(feedService as FeedService),
          authProvider.overrideWith(
            (ref) =>
                FakeAuthNotifier(User(id: 'me', email: '', displayName: 'Me')),
          ),
          copyTicketProvider.overrideWithValue(({
            required String userId,
            required String ticketId,
            required List<TipModel> tips,
            String? sourceUserId,
            FirebaseFirestore? firestore,
          }) async {
            copyCalled = true;
            return 'c1';
          }),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(body: HomeFeedWidget()),
        ),
      ),
    );

    controller.add([item]);
    await tester.pump();

    final otherLikeFinder = find.widgetWithIcon(IconButton, Icons.thumb_up);
    expect(otherLikeFinder, findsWidgets); // vagy .at(index) konkrét pozícióval
    await tester.tap(otherLikeFinder.first);
    await tester.pump();
    expect(feedService.likeCalls, 1);

    await tester.tap(find.byKey(const Key('copyButton')));
    await tester.pumpAndSettle();
    expect(copyCalled, isTrue);
    expect(find.text('Ticket copied!'), findsOneWidget);
  });

  testWidgets('Error state renders safely', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          feedStreamProvider.overrideWith((ref) => Stream.error('err')),
          authProvider.overrideWith((ref) => FakeAuthNotifier(null)),
          copyTicketProvider.overrideWithValue(
            ({
              required String userId,
              required String ticketId,
              required List<TipModel> tips,
              String? sourceUserId,
              FirebaseFirestore? firestore,
            }) async => 'id',
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(body: HomeFeedWidget()),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(SizedBox), findsOneWidget);
  });
}
