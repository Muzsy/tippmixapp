import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/widgets/home_profile_header.dart';
import 'package:tippmixapp/widgets/guest_promo_tile.dart';
import 'package:tippmixapp/widgets/home/user_stats_header.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

void main() {
  testWidgets('renders GuestPromoTile when user is not logged in', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Scaffold(body: HomeProfileHeader(isLoggedIn: _false)),
      ),
    );
    expect(find.byType(GuestPromoTile), findsOneWidget);
  });

  testWidgets('renders UserStatsHeader when user is logged in', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Scaffold(body: HomeProfileHeader(isLoggedIn: _true)),
      ),
    );
    expect(find.byType(UserStatsHeader), findsOneWidget);
    expect(find.byType(GuestPromoTile), findsNothing);
  });
}

bool _false() => false;
bool _true() => true;
