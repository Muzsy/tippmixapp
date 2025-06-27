import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/widgets/home/home_tile_daily_bonus.dart';
import 'package:tippmixapp/services/coin_service.dart';

class FakeCoinService extends CoinService {
  bool claimed = false;
  int claimCalls = 0;

  @override
  Future<bool> hasClaimedToday({auth, firestore}) async => claimed;

  @override
  Future<void> claimDailyBonus() async {
    claimCalls++;
    claimed = true;
  }
}

void main() {
  testWidgets('Daily bonus claim flow', (tester) async {
    final fakeService = FakeCoinService();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: HomeTileDailyBonus(coinService: fakeService),
          ),
        ),
      ),
    );

    // Allow future to resolve
    await tester.pumpAndSettle();
    expect(find.text('Collect'), findsOneWidget);

    await tester.tap(find.text('Collect'));
    await tester.pumpAndSettle();

    expect(fakeService.claimCalls, 1);
    expect(find.text('Collected'), findsOneWidget);
  });
}
