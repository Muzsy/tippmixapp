import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/features/filters/events_filter.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/widgets/events_filter_bar.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

void main(){
  testWidgets('renders and calls onChanged', (tester) async{
    final src = [
      OddsEvent(id:'1', sportKey:'soccer', sportTitle:'Soccer', homeTeam:'A', awayTeam:'B', countryName:'Hungary', leagueName:'NB I', commenceTime: DateTime.now(), bookmakers: const []),
      OddsEvent(id:'2', sportKey:'soccer', sportTitle:'Soccer', homeTeam:'C', awayTeam:'D', countryName:'England', leagueName:'Premier League', commenceTime: DateTime.now(), bookmakers: const []),
    ];
    var called = false;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: EventsFilterBar(source: src, value: const EventsFilter(), onChanged: (_){called=true;})),
    ));
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('England').last);
    await tester.pumpAndSettle();
    expect(called, true);
  });
}
