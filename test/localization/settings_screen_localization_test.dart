import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

void main() {
  test('AppLocalizations provides settings keys for all locales', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final loc = await AppLocalizations.delegate.load(locale);
      expect(loc.settings_title, isNotEmpty);
      expect(loc.settings_theme, isNotEmpty);
      expect(loc.settings_dark_mode, isNotEmpty);
      expect(loc.settings_language, isNotEmpty);
      expect(loc.settings_logout, isNotEmpty);
    }
  });
}
