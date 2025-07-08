import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_route.dart';
import '../../services/analytics_service.dart';
import 'email_field.dart';
import "package:go_router/go_router.dart";
import 'password_field.dart';
import '../../widgets/social_login_buttons.dart';

class LoginForm extends ConsumerStatefulWidget {
  final String variant;
  const LoginForm({super.key, required this.variant});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final error = await ref
        .read(authProvider.notifier)
        .login(_emailCtrl.text, _passCtrl.text);
    if (error == null) {
      await ref
          .read(analyticsServiceProvider)
          .logLoginSuccess(widget.variant);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        EmailField(
          controller: _emailCtrl,
          focusNode: _emailFocus,
          nextFocus: _passFocus,
        ),
        const SizedBox(height: 8),
        PasswordField(
          controller: _passCtrl,
          focusNode: _passFocus,
          onSubmit: _submit,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _submit,
          child: Text(loc.login_button),
        ),
        const SizedBox(height: 16),
        const SocialLoginButtons(),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.goNamed(AppRoute.register.name),
          child: Text(loc.register_link),
        ),
        ],
      ),
    );
  }
}
