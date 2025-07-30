// Validation helpers returning l10n keys

String? validateEmail(String? email) {
  if (email == null || email.isEmpty) return null;
  final regex = RegExp(r"^[\w.!#%&'*+/=?^_`{|}~-]+@[^\s@]+\.[^\s@]+$");
  return regex.hasMatch(email) ? null : 'errorInvalidEmail';
}

String? validatePassword(String? password) {
  if (password == null || password.isEmpty) return null;
  final hasLower = RegExp(r'[a-z]').hasMatch(password);
  final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
  final hasDigit = RegExp(r'\d').hasMatch(password);
  final hasSpecial = RegExp(
    r'[!@#\$&*~%^()_+=\-{}\[\]|:;<>,.?/]',
  ).hasMatch(password);
  final meetsLength = password.length >= 12;
  return hasLower && hasUpper && hasDigit && hasSpecial && meetsLength
      ? null
      : 'errorWeakPassword';
}

String passwordStrength(String password) {
  var score = 0;
  if (password.length >= 12) score++;
  if (RegExp(r'[A-Z]').hasMatch(password)) score++;
  if (RegExp(r'[a-z]').hasMatch(password)) score++;
  if (RegExp(r'\d').hasMatch(password)) score++;
  if (RegExp(r'[!@#\$&*~%^()_+=\-{}\[\]|:;<>,.?/]').hasMatch(password)) score++;
  if (score >= 4) return 'passwordStrengthStrong';
  if (score >= 3) return 'passwordStrengthMedium';
  if (score >= 2) return 'passwordStrengthWeak';
  return 'passwordStrengthVeryWeak';
}
