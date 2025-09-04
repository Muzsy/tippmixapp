import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/screens/profile_screen.dart';

void main() {
  testWidgets('shows placeholder when url is null', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => buildAvatar(context, null, 'Alice'),
        ),
      ),
    );
    expect(find.text('A'), findsOneWidget);
    expect(find.byType(ClipRRect), findsNothing);
  });

  testWidgets('shows rounded square when url provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => buildAvatar(context, 'http://example.com/a.png', 'Alice'),
        ),
      ),
    );
    expect(find.byType(ClipRRect), findsOneWidget);
  });
}
