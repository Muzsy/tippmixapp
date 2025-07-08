import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/main.dart' as app;
import 'package:tippmixapp/l10n/app_localizations_en.dart';

void main() {
  final loc = AppLocalizationsEn();

  testWidgets('guest tap on bet slip shows login dialog', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(loc.bets_title));
    await tester.pumpAndSettle();

    expect(find.text(loc.login_required_title), findsOneWidget);

    await tester.tap(find.text(loc.dialog_cancel));
    await tester.pumpAndSettle();
    expect(find.text(loc.login_required_title), findsNothing);
  });
}
