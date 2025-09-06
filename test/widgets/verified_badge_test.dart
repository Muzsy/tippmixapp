import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/widgets/verified_badge.dart';

void main() {
  testWidgets('renders verified icon', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: VerifiedBadge()));
    expect(find.byIcon(Icons.verified), findsOneWidget);
  });
}
