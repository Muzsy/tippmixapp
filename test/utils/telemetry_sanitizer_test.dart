import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/utils/telemetry_sanitizer.dart';

void main() {
  group('TelemetrySanitizer', () {
    test('normalizeTicketId replaces disallowed and trims length', () {
      final input = ' t!ck#et:ID/with spaces and symbols '*3; // long + symbols
      final out = TelemetrySanitizer.normalizeTicketId(input);
      expect(out.isNotEmpty, true);
      expect(out.length <= 64, true);
      expect(out.contains(' '), false);
      expect(out.contains('!'), false);
      expect(out.contains('/'), false);
    });

    test('normalizeTicketId returns unknown for null/empty', () {
      expect(TelemetrySanitizer.normalizeTicketId(null), 'unknown');
      expect(TelemetrySanitizer.normalizeTicketId('   '), 'unknown');
    });

    test('normalizeStatus maps aliases and clamps unknown', () {
      expect(TelemetrySanitizer.normalizeStatus('void'), 'voided');
      expect(TelemetrySanitizer.normalizeStatus('WON'), 'won');
      expect(TelemetrySanitizer.normalizeStatus('weird'), 'pending');
    });

    test('safeCount clamps to range and casts', () {
      expect(TelemetrySanitizer.safeCount(-5), 0);
      expect(TelemetrySanitizer.safeCount(5.7), 5);
      expect(TelemetrySanitizer.safeCount(999999999), 100000);
    });

    test('safeAmount clamps and rounds', () {
      expect(TelemetrySanitizer.safeAmount(-10), 0);
      expect(TelemetrySanitizer.safeAmount(12.3456, precision: 2), 12.35);
      expect(TelemetrySanitizer.safeAmount(1e20, max: 100), 100);
    });
  });
}

