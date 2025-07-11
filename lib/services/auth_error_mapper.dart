import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class AuthErrorMapper {
  String map(BuildContext context, FirebaseAuthException e) {
    final loc = AppLocalizations.of(context)!;
    switch (e.code) {
      case 'user-not-found':
        return loc.auth_error_user_not_found;
      case 'wrong-password':
        return loc.auth_error_wrong_password;
      case 'email-already-in-use':
        return loc.auth_error_email_already_in_use;
      case 'invalid-email':
        return loc.auth_error_invalid_email;
      case 'weak-password':
        return loc.auth_error_weak_password;
      case 'hibp':
        return loc.password_pwned_error;
      case 'recaptcha':
        return loc.recaptcha_failed_error;
      case 'network_timeout':
        return loc.unknown_network_error;
      default:
        return loc.auth_error_unknown;
    }
  }
}
