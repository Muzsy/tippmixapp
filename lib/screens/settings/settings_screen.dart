import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/controllers/app_locale_controller.dart';
import 'package:tippmixapp/controllers/app_theme_controller.dart';
import 'package:tippmixapp/services/theme_service.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/providers/auth_provider.dart';

/// Screen allowing the user to change theme, language and log out.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _aiRecommendations = false;
  bool _pushNotifications = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final themeMode = ref.watch(appThemeControllerProvider);
    final locale = ref.watch(appLocaleControllerProvider);
    final theme = ref.watch(themeServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings_title)),
      body: ListView(
        children: [
          ListTile(
            title: Text(loc.settings_theme),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              onChanged: (mode) {
                if (mode != null) {
                  ref
                      .read(appThemeControllerProvider.notifier)
                      .setThemeMode(mode);
                }
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(loc.settings_theme_system),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(loc.settings_theme_light),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(loc.settings_theme_dark),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(loc.settings_dark_mode),
            value: theme.isDark,
            onChanged: (_) {
              ref.read(themeServiceProvider.notifier).toggleDarkMode();
            },
          ),
          ListTile(
            title: Text(loc.settings_language),
            trailing: DropdownButton<Locale>(
              value: locale,
              onChanged: (l) {
                if (l != null) {
                  ref
                      .read(appLocaleControllerProvider.notifier)
                      .setLocale(l);
                }
              },
              items: const [
                DropdownMenuItem(value: Locale('hu'), child: Text('HU')),
                DropdownMenuItem(value: Locale('en'), child: Text('EN')),
                DropdownMenuItem(value: Locale('de'), child: Text('DE')),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(loc.settings_ai_recommendations),
            value: _aiRecommendations,
            onChanged: (v) => setState(() => _aiRecommendations = v),
          ),
          SwitchListTile(
            title: Text(loc.settings_push_notifications),
            value: _pushNotifications,
            onChanged: (v) => setState(() => _pushNotifications = v),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(loc.settings_logout),
            onTap: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}
