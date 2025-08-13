import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tippmixapp/l10n/app_localizations.dart';
import '../routes/app_route.dart';

/// Dialog displayed when a guest user tries to access a protected route.
class LoginRequiredDialog extends StatelessWidget {
  const LoginRequiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return AlertDialog(
      semanticLabel: loc.login_required_title,
      title: Text(loc.login_required_title),
      content: Text(loc.login_required_message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.dialog_cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.goNamed(AppRoute.login.name);
          },
          child: Text(loc.login_button),
        ),
      ],
    );
  }
}
