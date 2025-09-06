import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/models/feed_event_type.dart';
import 'package:tipsterino/models/feed_model.dart';
import 'package:tipsterino/widgets/home/home_tile_feed_activity.dart';

void main() {
  testWidgets('renders feed event and handles CTA', (tester) async {
    var tapped = false;
    final entry = FeedModel(
      userId: 'alice',
      eventType: FeedEventType.comment,
      message: 'msg',
      timestamp: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: HomeTileFeedActivity(
              entry: entry,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Latest activity'), findsOneWidget);
    expect(find.textContaining('alice'), findsOneWidget);

    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('hidden when no event', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Scaffold(body: SizedBox.shrink()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(Card), findsNothing);
  });
}
