import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/feed_event_type.dart';
import 'package:tippmixapp/models/feed_model.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/providers/feed_provider.dart';
import 'package:tippmixapp/widgets/home_feed.dart';
import 'package:tippmixapp/widgets/components/comment_modal.dart';
import 'package:tippmixapp/widgets/components/report_dialog.dart';
import 'package:tippmixapp/services/auth_service.dart';

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(User? user) : super(FakeAuthService()) {
    state = user;
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
  User? get currentUser => _current;
}

void main() {
  testWidgets('HomeFeedWidget shimmer and empty state', (tester) async {
    final controller = StreamController<List<FeedModel>>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          feedStreamProvider.overrideWith((ref) => controller.stream),
          authProvider.overrideWith((ref) => FakeAuthNotifier(null)),
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
              (ref) => FakeAuthNotifier(User(id: 'u1', email: '', displayName: 'me'))),
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

    final likeButton = find.byIcon(Icons.thumb_up);
    expect(tester.widget<IconButton>(likeButton).onPressed, isNull);

    await tester.tap(find.byIcon(Icons.comment));
    await tester.pumpAndSettle();
    expect(find.byType(CommentModal), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.report));
    await tester.pumpAndSettle();
    expect(find.byType(ReportDialog), findsOneWidget);
  });
}
