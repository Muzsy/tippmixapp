import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/widgets/home/home_tile_educational_tip.dart';

class FakeRandom extends Random {
  final int value;
  FakeRandom(this.value);
  @override
  int nextInt(int max) => value % max;
}

void main() {
  testWidgets('shows all tips based on random index and handles CTA', (tester) async {
    final tips = <String>[];
    for (var i = 0; i < 3; i++) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: HomeTileEducationalTip(
              random: FakeRandom(i),
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      tips.add(
        tester.widget<Text>(find.descendant(of: find.byType(Column), matching: find.byType(Text)).at(1)).data!,
      );
    }
    expect(tips.toSet().length, 3);
    expect(find.text('Betting tip'), findsOneWidget);
    await tester.tap(find.text('More tips'));
  });
}
