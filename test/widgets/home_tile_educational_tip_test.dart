import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  double nextDoubleInRange(double min, double max) =>
      min + (value.toDouble() % (max - min));

  int nextSign() => value.isEven ? 1 : -1;

  double nextExponential() {
    // Provide a simple fake implementation
    return value.toDouble();
  }
}

void main() {
  const jsonData = '''
  {"tips":[
    {"id":"tip_1","en":"e1","hu":"h1","de":"d1"},
    {"id":"tip_2","en":"e2","hu":"h2","de":"d2"},
    {"id":"tip_3","en":"e3","hu":"h3","de":"d3"},
    {"id":"tip_4","en":"e4","hu":"h4","de":"d4"}
  ]}''';

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
          final key = utf8.decode(message!.buffer.asUint8List());
          if (key == 'lib/assets/educational_tips.json') {
            return ByteData.view(
              Uint8List.fromList(utf8.encode(jsonData)).buffer,
            );
          }
          return null;
        });
  });

  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  testWidgets('shows all tips based on random index and handles CTA', (
    tester,
  ) async {
    final tips = <String>[];
    for (var i = 0; i < 4; i++) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: HomeTileEducationalTip(random: FakeRandom(i), onTap: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      tips.add(
        tester
            .widget<Text>(
              find
                  .descendant(
                    of: find.byType(Column),
                    matching: find.byType(Text),
                  )
                  .at(1),
            )
            .data!,
      );
    }
    expect(tips.toSet().length, 4);
    expect(find.text('Betting tip'), findsOneWidget);
    await tester.tap(find.text('More tips'));
  });
}
