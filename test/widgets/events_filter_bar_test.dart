import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/features/filters/events_filter.dart';
import 'package:tipsterino/models/odds_event.dart';
import 'package:tipsterino/widgets/events_filter_bar.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

void main() {
  testWidgets('renders and calls onChanged', (tester) async {
    final src = [
      OddsEvent(
        id: '1',
        sportKey: 'soccer',
        sportTitle: 'Soccer',
        homeTeam: 'A',
        awayTeam: 'B',
        countryName: 'Hungary',
        leagueName: 'NB I',
        commenceTime: DateTime.now(),
        bookmakers: const [],
      ),
      OddsEvent(
        id: '2',
        sportKey: 'soccer',
        sportTitle: 'Soccer',
        homeTeam: 'C',
        awayTeam: 'D',
        countryName: 'England',
        leagueName: 'Premier League',
        commenceTime: DateTime.now(),
        bookmakers: const [],
      ),
    ];
    var called = false;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: EventsFilterBar(
            source: src,
            value: const EventsFilter(),
            onChanged: (_) {
              called = true;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('England').last);
    await tester.pumpAndSettle();
    expect(called, true);
  });

  testWidgets('changing country resets league', (tester) async {
    final src = [
      OddsEvent(
        id: '1',
        sportKey: 'soccer',
        sportTitle: 'Soccer',
        homeTeam: 'A',
        awayTeam: 'B',
        countryName: 'Hungary',
        leagueName: 'NB I',
        commenceTime: DateTime.now(),
        bookmakers: const [],
      ),
      OddsEvent(
        id: '2',
        sportKey: 'soccer',
        sportTitle: 'Soccer',
        homeTeam: 'C',
        awayTeam: 'D',
        countryName: 'England',
        leagueName: 'Premier League',
        commenceTime: DateTime.now(),
        bookmakers: const [],
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: EventsFilterBar(
            source: src,
            value: const EventsFilter(),
            onChanged: (_) {},
          ),
        ),
      ),
    );

    // Select country Hungary
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hungary').last);
    await tester.pumpAndSettle();
    // Select league NB I
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('NB I').last);
    await tester.pumpAndSettle();
    // Change country to England
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('England').last);
    await tester.pumpAndSettle();

    final leagueField = tester.state<FormFieldState<String>>(
      find.byType(DropdownButtonFormField<String>).last,
    );
    expect(leagueField.value, '');
  });
}
