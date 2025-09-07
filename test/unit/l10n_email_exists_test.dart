import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

void main() {
  test('new l10n keys exist for all locales', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final loc = await AppLocalizations.delegate.load(locale);
      expect(loc.errorEmailExists, isNotEmpty);
      expect(loc.loaderCheckingEmail, isNotEmpty);
    }
  });
}
