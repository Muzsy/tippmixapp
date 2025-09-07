import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/screens/forum/thread_view_screen.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

void main() {
  testWidgets('composer disabled when locked', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ThreadViewScreen(threadId: 't1', locked: true),
    ));
    final sendButton = find.byIcon(Icons.send);
    expect(tester.widget<IconButton>(sendButton).onPressed, isNull);
  });
}
