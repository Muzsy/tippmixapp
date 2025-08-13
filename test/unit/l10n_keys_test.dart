import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

void main() {
  test('l10n keys exist for all locales', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final loc = await AppLocalizations.delegate.load(locale);
      expect(loc.errorInvalidEmail, isNotEmpty);
      expect(loc.errorWeakPassword, isNotEmpty);
      expect(loc.passwordStrengthVeryWeak, isNotEmpty);
      expect(loc.passwordStrengthStrong, isNotEmpty);
      expect(loc.btnContinue, isNotEmpty);
      expect(loc.appActionsMoreBets, isNotEmpty);
    }
  });
}
