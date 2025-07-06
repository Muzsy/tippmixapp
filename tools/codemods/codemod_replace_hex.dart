// tools/codemods/codemod_replace_hex.dart
// Codemod script replacing hard-coded hex colors with Theme references.
// Supports --dry-run and --apply. Use --help for usage info.

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;

final _hexRegex = RegExp(r'0xFF[0-9A-Fa-f]{6}');

void main(List<String> args) {
  final parser = ArgParser()
    ..addFlag('dry-run', abbr: 'n', defaultsTo: true, negatable: false,
        help: 'List planned replacements without modifying files.')
    ..addFlag('apply', abbr: 'a', negatable: false,
        help: 'Apply replacements to files.')
    ..addFlag('help', abbr: 'h', negatable: false,
        help: 'Show usage information.');

  final opts = parser.parse(args);
  if (opts['help'] as bool) {
    _printHelp(parser);
    return;
  }

  final dryRun = !(opts['apply'] as bool);
  final logFile = File('codemod_${dryRun ? 'dryrun' : 'apply'}.log')
    ..createSync(recursive: true)
    ..writeAsStringSync('');

  final dartFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (final file in dartFiles) {
    final rel = p.relative(file.path);
    var lines = file.readAsLinesSync();
    var modified = false;
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      for (final match in _hexRegex.allMatches(line).toList().reversed) {
        final hex = match.group(0)!;
        final repl = _suggestReplacement(hex);
        logFile.writeAsStringSync('$rel:${i + 1}: $hex -> $repl\n',
            mode: FileMode.append);
        if (!dryRun) {
          line = line.replaceRange(match.start, match.end, repl);
          modified = true;
        }
      }
      lines[i] = line;
    }
    if (!dryRun && modified) {
      file.writeAsStringSync(lines.join('\n'));
    }
  }

  stdout.writeln('Codemod ${dryRun ? 'dry-run' : 'apply'} finished. Log: ${logFile.path}');
}

String _suggestReplacement(String hex) {
  final v = hex.toUpperCase();
  if (v == '0xFFFF0000') return 'Theme.of(context).colorScheme.error';
  if (v == '0xFFFFFFFF') return 'Colors.white';
  if (v == '0xFF000000') return 'Colors.black';
  final d = v.substring(4);
  if (d[0] == d[2] && d[1] == d[3] && d[2] == d[4] && d[3] == d[5]) {
    return 'Colors.grey';
  }
  return 'Theme.of(context).colorScheme.primary';
}

void _printHelp(ArgParser parser) {
  stdout.writeln('Replace hard-coded hex colors with Theme references.');
  stdout.writeln(parser.usage);
  stdout.writeln('');
  stdout.writeln('Examples:');
  stdout.writeln('  dart run tools/codemods/codemod_replace_hex.dart --dry-run');
  stdout.writeln('  dart run tools/codemods/codemod_replace_hex.dart --apply');
}
