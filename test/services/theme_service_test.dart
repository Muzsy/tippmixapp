import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/services/theme_service.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

void main() {
  group('ThemeService', () {
    test('initial state', () {
      final service = ThemeService();
      expect(service.state.schemeIndex, 0);
      expect(service.state.isDark, isFalse);
    });

    test('toggleTheme cycles schemes', () {
      final service = ThemeService();
      service.toggleTheme();
      expect(service.state.schemeIndex, 1);
      for (var i = 1; i < FlexScheme.values.length; i++) {
        service.toggleTheme();
      }
      expect(service.state.schemeIndex, 0);
    });

    test('toggleDarkMode switches flag', () {
      final service = ThemeService();
      service.toggleDarkMode();
      expect(service.state.isDark, isTrue);
      service.toggleDarkMode();
      expect(service.state.isDark, isFalse);
    });

    test('setScheme only accepts valid indexes', () {
      final service = ThemeService();
      service.setScheme(2);
      expect(service.state.schemeIndex, 2);
      service.setScheme(-1);
      expect(service.state.schemeIndex, 2);
      service.setScheme(999);
      expect(service.state.schemeIndex, 2);
    });

    test('notifies listeners on state changes', () {
      final service = ThemeService();
      final emitted = <ThemeState>[];
      final remove = service.addListener(emitted.add, fireImmediately: false);

      service.toggleDarkMode();
      service.setScheme(3);

      remove();

      expect(emitted.length, 2);
      expect(emitted.first.isDark, isTrue);
      expect(emitted.last.schemeIndex, 3);
    });
  });
}
