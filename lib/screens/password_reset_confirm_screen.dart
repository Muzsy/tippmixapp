import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import '../routes/app_route.dart';

class PasswordResetConfirmScreen extends StatelessWidget {
  const PasswordResetConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.password_reset_title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.password_reset_email_sent),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.goNamed(AppRoute.login.name);
              },
              child: Text(loc.ok),
            ),
          ],
        ),
      ),
    );
  }
}
