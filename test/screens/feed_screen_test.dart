import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/screens/feed_screen.dart';
import 'package:tippmixapp/widgets/home_feed.dart';

void main() {
  testWidgets('FeedScreen displays HomeFeedWidget', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: FeedScreen(),
        ),
      ),
    );

    expect(find.byType(HomeFeedWidget), findsOneWidget);
    expect(find.text('Feed'), findsOneWidget);
  });
}

