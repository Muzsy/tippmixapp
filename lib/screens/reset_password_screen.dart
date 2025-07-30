import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../routes/app_route.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String oobCode;
  const ResetPasswordScreen({super.key, required this.oobCode});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() &&
        _passCtrl.text == _confirmCtrl.text) {
      await ref
          .read(authServiceProvider)
          .confirmPasswordReset(widget.oobCode, _passCtrl.text);
      if (mounted) {
        context.goNamed(AppRoute.login.name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.password_reset_title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: InputDecoration(hintText: loc.password_hint),
                validator: (v) => v != null && v.length >= 8
                    ? null
                    : loc.auth_error_weak_password,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: loc.confirm_password_hint,
                ),
                validator: (v) =>
                    v == _passCtrl.text ? null : loc.auth_error_weak_password,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _submit, child: Text(loc.dialog_send)),
            ],
          ),
        ),
      ),
    );
  }
}
