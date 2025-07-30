import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/widgets/streak_progress_bar.dart';

void main() {
  testWidgets('displays progress value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: StreakProgressBar(streakDays: 3)),
    );

    expect(find.text('Streak: 3/7'), findsOneWidget);
  });
}
