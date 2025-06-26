import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import '../routes/app_route.dart';
import '../models/auth_state.dart';

class LoginRegisterScreen extends ConsumerStatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  ConsumerState<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends ConsumerState<LoginRegisterScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    String? error;
    if (_isLogin) {
      error = await ref.read(authProvider.notifier).login(
        _emailCtrl.text,
        _passCtrl.text,
      );
    } else {
      if (_passCtrl.text != _confirmCtrl.text) return;
      error = await ref.read(authProvider.notifier).register(
        _emailCtrl.text,
        _passCtrl.text,
      );
    }
    if (error != null && mounted) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_localizeError(loc, error))),
      );
    }
  }

  String _localizeError(AppLocalizations loc, String code) {
    switch (code) {
      case 'auth/user-not-found':
        return loc.auth_error_user_not_found;
      case 'auth/wrong-password':
        return loc.auth_error_wrong_password;
      case 'auth/email-already-in-use':
        return loc.auth_error_email_already_in_use;
      case 'auth/invalid-email':
        return loc.auth_error_invalid_email;
      case 'auth/weak-password':
        return loc.auth_error_weak_password;
      default:
        return loc.auth_error_unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.user != null) context.goNamed(AppRoute.home.name);
    });

    return Scaffold(
      appBar: AppBar(title: Text(loc.login_title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text(loc.login_tab),
                  selected: _isLogin,
                  onSelected: (_) => setState(() => _isLogin = true),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(loc.register_tab),
                  selected: !_isLogin,
                  onSelected: (_) => setState(() => _isLogin = false),
                ),
              ],
            ),
            const SizedBox(height: 24),
              TextField(
                controller: _emailCtrl,
                decoration: InputDecoration(labelText: loc.email_hint),
              ),
            const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                decoration: InputDecoration(labelText: loc.password_hint),
                obscureText: true,
              ),
            if (!_isLogin) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _confirmCtrl,
                decoration: InputDecoration(labelText: loc.confirm_password_hint),
                obscureText: true,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: Text(_isLogin ? loc.login_button : loc.register_button),
            ),
          ],
        ),
      ),
    );
  }
}
