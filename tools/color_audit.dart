// tools/color_audit.dart
// -----------------------------------------------------------------------------
// TippmixApp – Sprint0 szín‑audit script
// -----------------------------------------------------------------------------
// Ez a Dart CLI‑eszköz a teljes projekt (alapértelmezésben a lib/ mappa) forrásfájlait
// átvizsgálja hard‑coded színek után. Kétféle előfordulást keres:
//   1. Hex‑alapú Color: pl. 0xFF123456, 0xFFABCDEF stb.
//   2. Material alapszín név: Colors.red, Colors.blue, stb.
// A találatokat CSV‑be menti (tools/reports/color_audit.csv) az alábbi oszlopokkal:
//   token  – a talált szín stringje (pl. 0xFF123456, Colors.red)
//   file   – forrásfájl relatív útvonala
//   line   – sorszám (1‑indextől)
//   count  – mindig 1 (könnyebb aggregálni pivottal)
//   category – üres (T0.3 lépésben kézzel tölthető)
// -----------------------------------------------------------------------------
// Futás:
//   dart run tools/color_audit.dart            # csak lib/‑et néz
//   dart run tools/color_audit.dart path/to/dir # opcionális gyökérmappa
//
// A script idempotens: minden futás előtt felülírja a CSV‑t.
// -----------------------------------------------------------------------------

import 'dart:io';
import 'package:path/path.dart' as p;

final _hexRegex = RegExp(r'0xFF[0-9A-Fa-f]{6}');
final _materialRegex = RegExp(r'Colors\.[A-Za-z_]+');

Future main(List<String> args) async {
  final rootDir = args.isEmpty ? Directory('lib') : Directory(args.first);
  if (!rootDir.existsSync()) {
    stderr.writeln('Hiba: a megadott könyvtár nem létezik: ${rootDir.path}');
    exitCode = 1;
    return;
  }

  final output = File('tools/reports/color_audit.csv')
    ..createSync(recursive: true);
  output.writeAsStringSync('token,file,line,count,category\n');

  final dartFiles = rootDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (final file in dartFiles) {
    final relPath = p.relative(file.path, from: Directory.current.path);
    final lines = await file.readAsLines();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      for (final match in _hexRegex.allMatches(line)) {
        _record(output, match.group(0)!, relPath, i + 1);
      }
      for (final match in _materialRegex.allMatches(line)) {
        _record(output, match.group(0)!, relPath, i + 1);
      }
    }
  }

  stdout.writeln('Szín‑audit kész! Eredmény: tools/reports/color_audit.csv');
}

void _record(File csv, String token, String file, int line) {
  csv.writeAsStringSync('$token,$file,$line,1,\n', mode: FileMode.append);
}
