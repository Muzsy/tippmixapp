import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/screens/badges/badge_screen.dart';
import 'package:tippmixapp/widgets/badge_grid_view.dart';

void main() {
  testWidgets('BadgeScreen displays grid', (tester) async {
    final controller = StreamController<List<String>>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userBadgesProvider.overrideWith((ref) => controller.stream),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: const BadgeScreen(),
        ),
      ),
    );

    controller.add(['badge_rookie']);
    await tester.pump();

    expect(find.byType(BadgeGridView), findsOneWidget);
  });

  testWidgets('BadgeScreen empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userBadgesProvider.overrideWith((ref) => Stream.empty()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: const BadgeScreen(),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('No badges yet'), findsOneWidget);
  });
}
