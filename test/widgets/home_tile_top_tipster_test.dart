import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/models/user_stats_model.dart';
import 'package:tipsterino/widgets/home/home_tile_top_tipster.dart';

void main() {
  testWidgets('renders stats and handles CTA', (tester) async {
    var tapped = false;
    final stats = UserStatsModel(
      uid: 'u1',
      displayName: 'Alice',
      coins: 100,
      totalBets: 5,
      totalWins: 5,
      winRate: 1.0,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: HomeTileTopTipster(stats: stats, onTap: () => tapped = true),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Player of the Day'), findsOneWidget);
    expect(find.textContaining('Alice'), findsOneWidget);

    await tester.tap(find.text('View tips'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });
}
