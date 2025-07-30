class AgeValidator {
  String? validate(DateTime? date) {
    if (date == null) return null;
    final now = DateTime.now();
    int age = now.year - date.year;
    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      age--;
    }
    if (age < 18) return 'dob_error_underage';
    if (date.isAfter(now)) return 'dob_error_future';
    return null;
  }
}
