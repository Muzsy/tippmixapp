import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/widgets/event_bet_card.dart';
import 'package:tippmixapp/services/api_football_service.dart';
import 'package:tippmixapp/models/h2h_market.dart';

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

class _NullApi extends ApiFootballService {
  @override
  Future<H2HMarket?> getH2HForFixture(int fixtureId) async => null;
}

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
    await tester.pumpWidget(_wrap(EventBetCard(event: e, apiService: _NullApi())));
    expect(find.text('Weitere Wetten'), findsOneWidget);
  });
}
