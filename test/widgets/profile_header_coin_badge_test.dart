import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/widgets/coin_badge.dart';

class _HeaderRow extends StatelessWidget {
  final Stream<int?> coins;
  const _HeaderRow(this.coins);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: StreamBuilder<int?>(
          stream: coins,
          builder: (context, snapshot) {
            return Row(
              children: [
                const CircleAvatar(),
                const Spacer(),
                CoinBadge(balance: snapshot.data),
              ],
            );
          },
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Header row shows coin badge', (tester) async {
    final controller = StreamController<int?>();
    await tester.pumpWidget(_HeaderRow(controller.stream));
    controller.add(42);
    await tester.pump();
    expect(find.textContaining('42'), findsOneWidget);
  });
}
