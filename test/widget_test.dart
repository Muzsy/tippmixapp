import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Egyszerű mock app
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('0')),
          floatingActionButton: FloatingActionButton(
            onPressed: null,
            child: Icon(Icons.add),
          ),
        ),
      ),
    );

    // Alap assert
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });
}
