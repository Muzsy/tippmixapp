import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/helpers/validators.dart';

void main() {
  group('validateEmail', () {
    test('returns error for invalid email', () {
      expect(validateEmail('invalid'), 'errorInvalidEmail');
    });

    test('returns null for valid email', () {
      expect(validateEmail('user@example.com'), isNull);
    });
  });

  group('validatePassword', () {
    test('returns error for weak password', () {
      expect(validatePassword('short'), 'errorWeakPassword');
    });

    test('returns null for strong password', () {
      expect(validatePassword('Abcd1234!@#\$'), isNull);
    });
  });

  group('passwordStrength', () {
    test('very weak password', () {
      expect(passwordStrength('abc'), 'passwordStrengthVeryWeak');
    });

    test('strong password', () {
      expect(passwordStrength('Abcd1234!@#\$'), 'passwordStrengthStrong');
    });
  });
}
