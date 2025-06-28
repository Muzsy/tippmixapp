import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_route.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final bool showAppBar;

  const ProfileScreen({super.key, this.showAppBar = true});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _loggingOut = false;
  String? _error;

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
        return widget.showAppBar
          ? Scaffold(
              appBar: AppBar(title: Text(loc.profile_title)),
              body: Center(child: Text(loc.not_logged_in)),
            )
          : Center(child: Text(loc.not_logged_in));
    }

    final content = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${loc.profile_email}: ${user.email}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('${loc.profile_name}: ${user.displayName}', style: const TextStyle(fontSize: 16)),
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
      ),
    );

    if (!widget.showAppBar) return content;

    return Scaffold(
      appBar: AppBar(title: Text(loc.profile_title)),
      body: content,
    );
  }
}
