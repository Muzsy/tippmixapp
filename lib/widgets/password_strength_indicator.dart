import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  const PasswordStrengthIndicator({super.key, required this.password});

  int _strength() {
    var score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'\d').hasMatch(password)) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final strength = _strength();
    String label;
    switch (strength) {
      case 3:
        label = loc.password_strength_strong;
        break;
      case 2:
        label = loc.password_strength_medium;
        break;
      default:
        label = loc.password_strength_weak;
        break;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: strength / 3),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
