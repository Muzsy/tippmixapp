// tools/color_chart.dart  —  VÉGLEGES, letesztelt verzió
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // --- CSV beolvasás ---
  final csv = File('tools/reports/color_audit_categorized.csv');
  if (!csv.existsSync()) {
    stderr.writeln('Hiányzó CSV: ${csv.path}');
    exit(1);
  }
  final lines = csv.readAsLinesSync();
  if (lines.length <= 1) {
    stderr.writeln('A CSV üres.');
    exit(1);
  }

  final cat = <String, int>{};
  final tok = <String, int>{};
  for (var i = 1; i < lines.length; i++) {
    final c = lines[i].split(',');
    if (c.length < 5) continue;
    final token = c[0];
    final cnt = int.tryParse(c[3]) ?? 1;
    final catg = c[4].isEmpty ? 'uncategorized' : c[4];
    cat[catg] = (cat[catg] ?? 0) + cnt;
    tok[token] = (tok[token] ?? 0) + cnt;
  }
  final top10 =
      (tok.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
          .take(10)
          .toList();

  // --- Widget-fa csak annyi, amennyi feltétlen kell ---
  final root = Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(size: Size(800, 600)),
      child: SizedBox(
        width: 800,
        height: 600,
        child: Row(
          children: [
            // Pie
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    for (final e in cat.entries)
                      PieChartSectionData(
                        title: e.key,
                        value: e.value.toDouble(),
                      ),
                  ],
                ),
              ),
            ),
            // Bar
            Expanded(
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i >= top10.length) return const SizedBox.shrink();
                          return Text(
                            top10[i].key.replaceFirst('Colors.', ''),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < top10.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(toY: top10[i].value.toDouble()),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  // --- Screenshot ---
  final bytes = await ScreenshotController().captureFromWidget(
    root,
    pixelRatio: 2.0,
  );

  final out = File('tools/reports/color_usage_chart.png')
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes);

  stdout.writeln('Diagram mentve: ${p.normalize(out.path)}');
  // exit(0);                    // <- automatikusan kilép, nem kell kézzel „q”-zni
}
