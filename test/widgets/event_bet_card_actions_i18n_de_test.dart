import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/widgets/event_bet_card.dart';

Widget _wrap(Widget child) => MaterialApp(
  locale: const Locale('de'),
  supportedLocales: const [Locale('en'), Locale('hu'), Locale('de')],
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: Scaffold(body: child),
);

void main() {
  testWidgets('ActionPill címkék németül jelennek meg', (tester) async {
    final e = OddsEvent(
      id: '1',
      sportKey: 'soccer',
      sportTitle: 'Soccer',
      homeTeam: 'Real Soacha',
      awayTeam: 'Deportes Tolima',
      commenceTime: DateTime.now(),
      bookmakers: const [],
    );
    await tester.pumpWidget(_wrap(EventBetCard(event: e, h2hMarket: null)));
    expect(find.text('Weitere Wetten'), findsOneWidget);
  });
}
