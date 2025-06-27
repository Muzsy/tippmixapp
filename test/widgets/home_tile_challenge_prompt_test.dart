import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/widgets/home/home_tile_challenge_prompt.dart';
import 'package:tippmixapp/services/challenge_service.dart';

void main() {
  testWidgets('renders challenge and handles CTA', (tester) async {
    var tapped = false;
    final challenge = ChallengeModel(
      id: 'c1',
      type: ChallengeType.daily,
      endTime: DateTime.now().add(const Duration(hours: 1)),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: HomeTileChallengePrompt(
              challenge: challenge,
              onAccept: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Challenge awaits!'), findsOneWidget);
    expect(find.textContaining('Daily challenge'), findsOneWidget);

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('friend challenge text', (tester) async {
    final challenge = ChallengeModel(
      id: 'c2',
      type: ChallengeType.friend,
      username: 'Bob',
      endTime: DateTime.now().add(const Duration(hours: 1)),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: HomeTileChallengePrompt(challenge: challenge),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Bob challenged you'), findsOneWidget);
  });
}
