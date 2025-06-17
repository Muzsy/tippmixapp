import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

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
    final user = ref.watch(authProvider);

    if (user == null) {
      return Scaffold(
        body: Center(child: Text(loc.not_logged_in)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(loc.profile_title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${loc.profile_email}: ${user.email}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('${loc.profile_name}: ${user.displayName}', style: const TextStyle(fontSize: 16)),
            SizedBox(height: 32),
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 12),
            ],
            _loggingOut
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _loggingOut ? null : _logout,
                    child: Text(loc.profile_logout),
                  ),
          ],
        ),
      ),
    );
  }
}
