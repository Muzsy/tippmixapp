import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../routes/app_route.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).sendPasswordReset(_emailCtrl.text);
      if (mounted) {
        context.goNamed(AppRoute.passwordResetConfirm.name);
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
                controller: _emailCtrl,
                decoration: InputDecoration(hintText: loc.email_hint),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v != null && v.contains('@')
                    ? null
                    : loc.auth_error_invalid_email,
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
