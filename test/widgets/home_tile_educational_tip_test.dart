import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/widgets/home/home_tile_educational_tip.dart';

class FakeRandom implements Random {
  final int value;
  FakeRandom(this.value);

  @override
  int nextInt(int max) => value % max;

  @override
  double nextDouble() => value.toDouble();

  @override
  bool nextBool() => value.isEven;

  // The following methods are required by the Random interface in Dart SDK >=2.17

  // Not an override in Random, just a helper for testing
  double nextDoubleInRange(double min, double max) => min + (value.toDouble() % (max - min));

  int nextSign() => value.isEven ? 1 : -1;

  double nextExponential() {
    // Provide a simple fake implementation
    return value.toDouble();
  }
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
