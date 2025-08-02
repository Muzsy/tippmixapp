import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/models/tip_model.dart';
import 'package:tippmixapp/providers/bet_slip_provider.dart';
import 'package:tippmixapp/providers/odds_api_provider.dart';
import 'package:tippmixapp/services/odds_api_service.dart';
import 'package:tippmixapp/services/odds_cache_wrapper.dart';
import 'package:tippmixapp/screens/events_screen.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

class _StubOddsNotifier extends OddsApiProvider {
  _StubOddsNotifier() : super(OddsCacheWrapper(OddsApiService()));

  @override
  Future<void> fetchOdds({required String sport}) async {
    state = OddsApiEmpty();
  }
}

void main() {
  testWidgets('FAB appears when tips present', (WidgetTester tester) async {
    final tip = TipModel(
      eventId: '1',
      eventName: 'Test vs Test',
      startTime: DateTime.now(),
      sportKey: 'soccer',
      bookmaker: 'TestBook',
      marketKey: 'h2h',
      outcome: 'Test',
      odds: 2.0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          betSlipProvider.overrideWith((ref) {
            final notifier = BetSlipProvider();
            notifier.addTip(tip);
            return notifier;
          }),
          oddsApiProvider.overrideWith((ref) => _StubOddsNotifier()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EventsScreen(sportKey: 'soccer', showAppBar: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('create_ticket_button')), findsOneWidget);
  });
}
