import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/reward_model.dart';
import 'package:tippmixapp/screens/rewards/rewards_screen.dart';
import 'package:tippmixapp/services/reward_service.dart';

class FakeRewardService extends RewardService {
  FakeRewardService(List<RewardModel> rewards) : super() {
    loadRewards(rewards);
  }
}

void main() {
  testWidgets('claiming reward removes it from list', (tester) async {
    final reward = RewardModel(
      id: 'r1',
      type: 'daily',
      title: 'Daily',
      description: 'desc',
      iconName: 'coin',
      isClaimed: false,
      onClaim: () async {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          rewardServiceProvider.overrideWith(() => FakeRewardService([reward])),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: RewardsScreen(),
        ),
      ),
    );

    expect(find.text('Daily'), findsOneWidget);
    await tester.tap(find.text('Claim'));
    await tester.pumpAndSettle();
    expect(find.text('Daily'), findsNothing);
  });
});
