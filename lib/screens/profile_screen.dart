import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import '../constants.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_route.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final bool showAppBar;

  const ProfileScreen({super.key, this.showAppBar = true});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isPrivate = false;
  final Map<String, bool> _fieldVisibility = {
    "city": true,
    "country": true,
    "friends": true,
    "favoriteSports": true,
    "favoriteTeams": true,
  };
  bool _loggingOut = false;
  String? _error;

  String _labelForKey(AppLocalizations loc, String key) {
    switch (key) {
      case 'city':
        return loc.profile_city;
      case 'country':
        return loc.profile_country;
      case 'friends':
        return loc.profile_friends;
      case 'favoriteSports':
        return loc.profile_favorite_sports;
      case 'favoriteTeams':
        return loc.profile_favorite_teams;
    }
    return key;
  }

  Future<void> _logout() async {
    setState(() {
      _loggingOut = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).logout();
      // Siker esetén a GoRouter authProvider state miatt visszairányít
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loggingOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;

    if (user == null) {
      if (!widget.showAppBar || Scaffold.maybeOf(context) != null) {
        return Center(child: Text(loc.not_logged_in));
      }
      return Scaffold(
        appBar: AppBar(title: Text(loc.profile_title)),
        body: Center(child: Text(loc.not_logged_in)),
      );
    }

    final content = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: const AssetImage(kDefaultAvatarPath),
          ),
          const SizedBox(height: 12),
          Text('${loc.profile_nickname}: ${user.displayName}',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('${loc.profile_email}: ${user.email}',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 32),
          SwitchListTile(
            title: Text(loc.profile_is_private),
            value: _isPrivate,
            onChanged: (v) => setState(() => _isPrivate = v),
          ),
          const Divider(),
          ..._fieldVisibility.keys.map((key) {
            return SwitchListTile(
              title: Text(_labelForKey(loc, key)),
              value: _fieldVisibility[key]!,
              onChanged: (v) => setState(() => _fieldVisibility[key] = v),
            );
          }),
          const SizedBox(height: 32),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],
            _loggingOut
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _loggingOut ? null : _logout,
                    child: Text(loc.profile_logout),
                  ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                context.goNamed(AppRoute.badges.name);
              },
              child: Text(loc.menuBadges),
            ),
          ],
        ),
      );

    if (!widget.showAppBar) return content;
    if (Scaffold.maybeOf(context) != null) {
      return content;
    }
    return Scaffold(
      appBar: AppBar(title: Text(loc.profile_title)),
      body: content,
    );
  }
}
