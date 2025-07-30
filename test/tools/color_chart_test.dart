// test/tools/color_chart_test.dart
import 'package:flutter_test/flutter_test.dart';
import '../../tools/color_chart.dart' as chart;

void main() {
  testWidgets(
    'Generate color chart',
    (tester) async {
      // run chart.main() async, hogy ne blokkoljon a tesztpump
      await tester.runAsync(() async {
        await chart.main(); // PNG elkészítése
      });

      // várjunk, míg minden frame befejeződik
      await tester.pumpAndSettle(const Duration(seconds: 1));
    },
    // 10 → 30 percre növeljük a timeoutot a heavy build miatt
    timeout: const Timeout(Duration(minutes: 30)),
  );
}
