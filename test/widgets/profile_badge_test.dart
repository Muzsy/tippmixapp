import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/models/badge.dart';
import 'package:tipsterino/widgets/profile_badge.dart';

void main() {
  testWidgets('ProfileBadgeGrid shows badges', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Scaffold(
          body: ProfileBadgeGrid(
            badges: [
              BadgeData(
                key: 'badge_rookie',
                iconName: 'star',
                condition: BadgeCondition.firstWin,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Rookie'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgets('ProfileBadgeGrid empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Scaffold(body: ProfileBadgeGrid(badges: [])),
      ),
    );

    expect(find.text('No badges yet'), findsOneWidget);
  });
}
