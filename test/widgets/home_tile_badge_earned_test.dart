import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/badge.dart';
import 'package:tippmixapp/models/earned_badge_model.dart';
import 'package:tippmixapp/widgets/home/home_tile_badge_earned.dart';

void main() {
  testWidgets('renders badge and handles CTA', (tester) async {
    var tapped = false;
    final badge = EarnedBadgeModel(
      badge: const BadgeData(
        key: 'badge_rookie',
        iconName: 'star',
        condition: BadgeCondition.firstWin,
      ),
      timestamp: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: HomeTileBadgeEarned(
              badge: badge,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Badge Earned'), findsOneWidget);
    expect(find.text('Rookie'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);

    await tester.tap(find.text('View all'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });
}
