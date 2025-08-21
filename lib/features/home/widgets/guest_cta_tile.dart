import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/routes/app_route.dart';

class GuestCtaTile extends StatelessWidget {
  const GuestCtaTile({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.home_guest_title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              loc.home_guest_subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => context.goNamed(AppRoute.login.name),
                  child: Text(loc.home_guest_login_button),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => context.goNamed(AppRoute.register.name),
                  child: Text(loc.home_guest_register_button),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
