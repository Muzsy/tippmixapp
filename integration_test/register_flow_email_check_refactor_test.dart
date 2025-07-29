import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tippmixapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('happy path registration', (t) async {
    app.main();
    await t.pumpAndSettle();
    // lépegetés Step1 → Step2 → Step3 (helper függvényekkel, lásd meglévő teszteket)
    // végén várjuk Home vagy EmailVerif képernyőt
    expect(find.textContaining('[REGISTER] SUCCESS'), findsOneWidget);
  });
}
