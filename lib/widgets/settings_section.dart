import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';

/// Settings section allowing theme toggle and logout action.
class SettingsSection extends ConsumerWidget {
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
