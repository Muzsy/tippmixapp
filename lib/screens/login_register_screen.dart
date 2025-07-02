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

class _LoginRegisterScreenState extends ConsumerState<LoginRegisterScreen>
    with SingleTickerProviderStateMixin {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(loc.login_welcome,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isLogin
                  ? _LoginForm(
                      key: const ValueKey('login'),
                      emailCtrl: _emailCtrl,
                      passCtrl: _passCtrl,
                      onSubmit: _submit,
                      loc: loc,
                    )
                  : _RegisterForm(
                      key: const ValueKey('register'),
                      emailCtrl: _emailCtrl,
                      passCtrl: _passCtrl,
                      confirmCtrl: _confirmCtrl,
                      onSubmit: _submit,
                      loc: loc,
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SocialLoginButton(
                  key: const Key('google_login_button'),
                  label: loc.google_login,
                  icon: Icons.g_mobiledata,
                  color: Colors.red,
                  onPressed: null,
                ),
                _SocialLoginButton(
                  key: const Key('apple_login_button'),
                  label: loc.apple_login,
                  icon: Icons.apple,
                  color: Colors.black,
                  onPressed: null,
                ),
                _SocialLoginButton(
                  key: const Key('facebook_login_button'),
                  label: loc.facebook_login,
                  icon: Icons.facebook,
                  color: Colors.blue,
                  onPressed: null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: Text(loc.forgot_password),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final VoidCallback onSubmit;
  final AppLocalizations loc;

  const _LoginForm({
    super.key,
    required this.emailCtrl,
    required this.passCtrl,
    required this.onSubmit,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: emailCtrl,
              decoration: InputDecoration(labelText: loc.email_hint),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: passCtrl,
              decoration: InputDecoration(labelText: loc.password_hint),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onSubmit,
              child: Text(loc.login_button),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController confirmCtrl;
  final VoidCallback onSubmit;
  final AppLocalizations loc;

  const _RegisterForm({
    super.key,
    required this.emailCtrl,
    required this.passCtrl,
    required this.confirmCtrl,
    required this.onSubmit,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: emailCtrl,
              decoration: InputDecoration(labelText: loc.email_hint),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: passCtrl,
              decoration: InputDecoration(labelText: loc.password_hint),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: confirmCtrl,
              decoration: InputDecoration(labelText: loc.confirm_password_hint),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onSubmit,
              child: Text(loc.register_button),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _SocialLoginButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          label: Text(label),
          style: ElevatedButton.styleFrom(backgroundColor: color),
        ),
      ),
    );
  }
}
