import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

class GuestPromoTile extends StatelessWidget {
  final VoidCallback? onLoginTap;
  final VoidCallback? onRegisterTap;
  const GuestPromoTile({super.key, this.onLoginTap, this.onRegisterTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final loc = AppLocalizations.of(context)!;
    final hasLogin = onLoginTap != null;
    final hasRegister = onRegisterTap != null;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: kElevationToShadow[1],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  loc.home_guest_title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(loc.home_guest_body, style: textTheme.bodyMedium),
          const SizedBox(height: 12),
          if (hasLogin || hasRegister)
            Row(
              children: [
                if (hasLogin)
                  FilledButton(
                    onPressed: onLoginTap,
                    child: Text(loc.home_cta_login),
                  ),
                if (hasLogin && hasRegister) const SizedBox(width: 8),
                if (hasRegister)
                  OutlinedButton(
                    onPressed: onRegisterTap,
                    child: Text(loc.home_cta_register),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
