import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/widgets/home/home_tile_daily_bonus.dart';
import 'package:tipsterino/services/coin_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

class FakeCoinService extends CoinService {
  FakeCoinService({
    required super.firestore,
  }); // Pass required arguments here if needed

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
    final fakeService = FakeCoinService(firestore: FakeFirebaseFirestore());

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(body: HomeTileDailyBonus(coinService: fakeService)),
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
