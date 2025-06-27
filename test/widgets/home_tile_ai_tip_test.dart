import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/widgets/home/home_tile_ai_tip.dart';
import 'package:tippmixapp/services/ai_tip_provider.dart';

class FakeAiTipProvider extends AiTipProvider {
  final AiTip? tip;
  int calls = 0;
  FakeAiTipProvider(this.tip);

  @override
  Future<AiTip?> getDailyTip() async {
    calls++;
    return tip;
  }
}

void main() {
  testWidgets('renders tip and handles CTA', (tester) async {
    var tapped = false;
    final provider = FakeAiTipProvider(AiTip(team: 'Bayern', percent: 78));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: HomeTileAiTip(
              tip: await provider.getDailyTip()!,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('AI Recommendation'), findsOneWidget);
    expect(find.textContaining('Bayern'), findsOneWidget);

    await tester.tap(find.text('View details'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('hidden when tip null', (tester) async {
    final provider = FakeAiTipProvider(null);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: provider.tip == null
                ? const SizedBox.shrink()
                : HomeTileAiTip(tip: provider.tip!),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(Card), findsNothing);
  });
}
