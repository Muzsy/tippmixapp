import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/config/badge_config.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/l10n/app_localizations_de.dart';
import 'package:tippmixapp/l10n/app_localizations_en.dart';
import 'package:tippmixapp/l10n/app_localizations_hu.dart';
import 'package:tippmixapp/screens/badges/badge_screen.dart';
import 'package:tippmixapp/widgets/badge_grid_view.dart';

Future<void> _pumpBadgeScreen(
  WidgetTester tester,
  StreamController<List<String>> controller, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [userBadgesProvider.overrideWith((ref) => controller.stream)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: const BadgeScreen(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('TC-01 displays badge grid', (tester) async {
    final controller = StreamController<List<String>>();
    await _pumpBadgeScreen(tester, controller);
    controller.add(['badge_rookie']);
    await tester.pump();

    expect(find.byType(BadgeGridView), findsOneWidget);
    expect(find.text(AppLocalizationsEn().badge_rookie_title), findsOneWidget);
  });

  testWidgets('TC-02 shows empty state', (tester) async {
    final controller = StreamController<List<String>>();
    await _pumpBadgeScreen(tester, controller);
    controller.add([]);
    await tester.pump();

    expect(
      find.text(AppLocalizationsEn().profile_badges_empty),
      findsOneWidget,
    );
  });

  testWidgets('TC-03 filter missing hides owned badges', (tester) async {
    final controller = StreamController<List<String>>();
    await _pumpBadgeScreen(tester, controller);
    controller.add(['badge_rookie']);
    await tester.pump();

    await tester.tap(find.byType(DropdownButton<BadgeFilter>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLocalizationsEn().badgeFilterMissing).last);
    await tester.pumpAndSettle();

    expect(find.text(AppLocalizationsEn().badge_rookie_title), findsNothing);
    expect(find.byType(Tooltip), findsNWidgets(badgeConfigs.length - 1));
  });

  testWidgets('TC-04 filter all shows every badge', (tester) async {
    final controller = StreamController<List<String>>();
    await _pumpBadgeScreen(tester, controller);
    controller.add(['badge_rookie']);
    await tester.pump();

    await tester.tap(find.byType(DropdownButton<BadgeFilter>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLocalizationsEn().badgeFilterAll).last);
    await tester.pumpAndSettle();

    expect(find.byType(Tooltip), findsNWidgets(badgeConfigs.length));
  });

  testWidgets('TC-05 opens detail dialog', (tester) async {
    final controller = StreamController<List<String>>();
    await _pumpBadgeScreen(tester, controller);
    controller.add(['badge_rookie']);
    await tester.pump();

    await tester.tap(find.text(AppLocalizationsEn().badge_rookie_title));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('TC-06 hero animation', (tester) async {
    final controller = StreamController<List<String>>();
    await _pumpBadgeScreen(tester, controller);
    controller.add(['badge_rookie']);
    await tester.pump();

    await tester.tap(find.text(AppLocalizationsEn().badge_rookie_title));
    await tester.pumpAndSettle();

    expect(find.byType(Hero), findsWidgets);
  });

  testWidgets('TC-07 localization HU', (tester) async {
    final controller = StreamController<List<String>>();
    await _pumpBadgeScreen(tester, controller, locale: const Locale('hu'));
    controller.add([]);
    await tester.pump();

    expect(
      find.text(AppLocalizationsHu().profile_badges_empty),
      findsOneWidget,
    );
  });

  testWidgets('TC-08 localization DE', (tester) async {
    final controller = StreamController<List<String>>();
    await _pumpBadgeScreen(tester, controller, locale: const Locale('de'));
    controller.add([]);
    await tester.pump();

    expect(
      find.text(AppLocalizationsDe().profile_badges_empty),
      findsOneWidget,
    );
  });

  testWidgets('TC-09 scroll stability with many badges', (tester) async {
    final controller = StreamController<List<String>>();
    await _pumpBadgeScreen(tester, controller);
    controller.add(List.filled(120, 'badge_rookie'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(BadgeGridView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
