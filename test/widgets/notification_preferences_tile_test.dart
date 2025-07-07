import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/widgets/notification_preferences_tile.dart';

void main() {
  testWidgets('toggles call callback', (tester) async {
    String? lastKey;
    bool? lastValue;
    final prefs = {
      'tips': true,
      'friendActivity': true,
      'badge': true,
      'rewards': true,
      'system': true,
    };

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: NotificationPreferencesTile(
            prefs: prefs,
            onChanged: (k, v) {
              lastKey = k;
              lastValue = v;
              prefs[k] = v;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tips'));
    await tester.pumpAndSettle();

    expect(lastKey, 'tips');
    expect(lastValue, isFalse);
    expect(prefs['tips'], isFalse);
  });
}
