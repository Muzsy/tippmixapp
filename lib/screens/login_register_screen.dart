import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

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
    if (_isLogin) {
      await ref.read(authProvider.notifier).login(
            _emailCtrl.text,
            _passCtrl.text,
          );
    } else {
      if (_passCtrl.text != _confirmCtrl.text) return;
      await ref.read(authProvider.notifier).register(
            _emailCtrl.text,
            _passCtrl.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    ref.listen<User?>(authProvider, (previous, next) {
      if (next != null) context.go('/');
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
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (!_isLogin) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _confirmCtrl,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
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
