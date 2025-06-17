import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';

/// Settings section allowing theme toggle and logout action.
class SettingsSection extends HookConsumerWidget {
  final bool showLogout;
  final VoidCallback onLogout;

  const SettingsSection({
    super.key,
    required this.showLogout,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text(loc.profile_theme),
          value: theme == AppColorTheme.pink,
          onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
        ),
        if (showLogout)
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(loc.profile_logout),
            onTap: onLogout,
          ),
      ],
    );
  }
}
