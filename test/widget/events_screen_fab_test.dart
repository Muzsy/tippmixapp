import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/models/tip_model.dart';
import 'package:tipsterino/providers/bet_slip_provider.dart';
import 'package:tipsterino/providers/odds_api_provider.dart';
import 'package:tipsterino/services/api_football_service.dart';
import 'package:tipsterino/services/odds_cache_wrapper.dart';
import 'package:tipsterino/screens/events_screen.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

class _StubOddsNotifier extends OddsApiProvider {
  _StubOddsNotifier() : super(OddsCacheWrapper(ApiFootballService()));

  @override
  Future<void> fetchOdds({
    required String sport,
    DateTime? date,
    String? country,
    String? league,
  }) async {
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
