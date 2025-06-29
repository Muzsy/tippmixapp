import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/l10n/app_localizations_de.dart';
import 'package:tippmixapp/l10n/app_localizations_en.dart';
import 'package:tippmixapp/l10n/app_localizations_hu.dart';
import 'package:tippmixapp/models/reward_model.dart';
import 'package:tippmixapp/screens/rewards/rewards_screen.dart';
import 'package:tippmixapp/services/reward_service.dart';

class FakeRewardService extends RewardService {
  FakeRewardService(List<RewardModel> rewards) : super() {
    loadRewards(rewards);
  }
}

Future<void> _pumpRewardsScreen(
  WidgetTester tester,
  List<RewardModel> rewards, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        rewardServiceProvider.overrideWith((ref) => FakeRewardService(rewards)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: const RewardsScreen(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('RC-01 displays reward list', (tester) async {
    final reward = RewardModel(
      id: 'r1',
      type: 'daily',
      title: 'Daily Bonus',
      description: 'desc',
      iconName: 'coin',
      isClaimed: false,
      onClaim: () async {},
    );

    await _pumpRewardsScreen(tester, [reward]);

    expect(find.text('Daily Bonus'), findsOneWidget);
    expect(find.text('desc'), findsOneWidget);
    expect(find.text(AppLocalizationsEn().rewardClaim), findsOneWidget);
  });

  testWidgets('RC-02 claiming reward removes it from list', (tester) async {
    bool claimed = false;
    final reward = RewardModel(
      id: 'r2',
      type: 'daily',
      title: 'Daily',
      description: 'desc',
      iconName: 'coin',
      isClaimed: false,
      onClaim: () async {
        claimed = true;
      },
    );

    await _pumpRewardsScreen(tester, [reward]);

    expect(find.text('Daily'), findsOneWidget);
    await tester.tap(find.text(AppLocalizationsEn().rewardClaim));
    await tester.pumpAndSettle();
    expect(find.text('Daily'), findsNothing);
    expect(claimed, isTrue);
  });

  testWidgets('RC-03 shows empty state text', (tester) async {
    await _pumpRewardsScreen(tester, []);

    expect(find.text(AppLocalizationsEn().rewardEmpty), findsOneWidget);
  });

  testWidgets('RC-04 localization HU', (tester) async {
    await _pumpRewardsScreen(tester, [], locale: const Locale('hu'));

    expect(find.text(AppLocalizationsHu().rewardEmpty), findsOneWidget);
  });

  testWidgets('RC-05 localization DE', (tester) async {
    await _pumpRewardsScreen(tester, [], locale: const Locale('de'));

    expect(find.text(AppLocalizationsDe().rewardEmpty), findsOneWidget);
  });

  testWidgets('RC-06 scroll stability with many rewards', (tester) async {
    final rewards = List.generate(
      150,
      (i) => RewardModel(
        id: 'r$i',
        type: 'daily',
        title: 'Reward $i',
        description: 'desc',
        iconName: 'coin',
        isClaimed: false,
        onClaim: () async {},
      ),
    );

    await _pumpRewardsScreen(tester, rewards);
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('RC-07 icon mapping for coin rewards', (tester) async {
    final reward = RewardModel(
      id: 'r3',
      type: 'daily',
      title: 'Coins',
      description: 'desc',
      iconName: 'coin',
      isClaimed: false,
      onClaim: () async {},
    );

    await _pumpRewardsScreen(tester, [reward]);

    expect(find.byIcon(Icons.attach_money), findsOneWidget);
  });

  testWidgets('RC-08 onClaim callback executes', (tester) async {
    bool called = false;
    final reward = RewardModel(
      id: 'r4',
      type: 'daily',
      title: 'Callback',
      description: 'desc',
      iconName: 'coin',
      isClaimed: false,
      onClaim: () async {
        called = true;
      },
    );

    await _pumpRewardsScreen(tester, [reward]);

    await tester.tap(find.text(AppLocalizationsEn().rewardClaim));
    await tester.pumpAndSettle();

    expect(called, isTrue);
  });
}
