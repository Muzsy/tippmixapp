import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_route.dart';
import '../../services/analytics_service.dart';
import "package:go_router/go_router.dart";
import '../../helpers/validators.dart';
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
  final _formKey = GlobalKey<FormState>();
  String? _emailError;
  String? _passError;
  Timer? _debounce;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _emailError = validateEmail(_emailCtrl.text);
      _passError = validatePassword(_passCtrl.text);
    });
    if (_emailError != null || _passError != null) return;
    final error = await ref
        .read(authProvider.notifier)
        .login(_emailCtrl.text, _passCtrl.text);
    if (error == null) {
      await ref.read(analyticsServiceProvider).logLoginSuccess(widget.variant);
    }
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _emailError = validateEmail(_emailCtrl.text);
        _passError = validatePassword(_passCtrl.text);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailCtrl,
              focusNode: _emailFocus,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _onChanged(),
              decoration: InputDecoration(
                labelText: loc.email_hint,
                errorText: _emailError == null ? null : loc.errorInvalidEmail,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passCtrl,
              focusNode: _passFocus,
              textInputAction: TextInputAction.done,
              onChanged: (_) => _onChanged(),
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: loc.password_hint,
                errorText: _passError == null ? null : loc.errorWeakPassword,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _submit, child: Text(loc.login_button)),
            const SizedBox(height: 16),
            const SocialLoginButtons(),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.goNamed(AppRoute.register.name),
              child: Text(loc.register_link),
            ),
          ],
        ),
      ),
    );
  }
}
