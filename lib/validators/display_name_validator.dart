class DisplayNameValidator {
  String? validate(String value) {
    final trimmed = value.trim();
    if (trimmed.length < 3) return 'name_error_short';
    if (trimmed.length > 24) return 'name_error_long';
    return null;
  }
}
