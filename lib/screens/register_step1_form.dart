import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/register_state_notifier.dart';
import '../widgets/password_strength_indicator.dart';

class RegisterStep1Form extends ConsumerStatefulWidget {
  const RegisterStep1Form({super.key});

  @override
  ConsumerState<RegisterStep1Form> createState() => _RegisterStep1FormState();
}

class _RegisterStep1FormState extends ConsumerState<RegisterStep1Form> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  Timer? _debounce;
  String? _emailError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _toggle() => setState(() => _obscure = !_obscure);

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final auth = ref.read(authServiceProvider);
      final unique = await auth.validateEmailUnique(_emailCtrl.text);
      if (!unique) {
        setState(() {
          _emailError = AppLocalizations.of(
            context,
          )!.auth_error_email_already_in_use;
        });
        return;
      }
      ref
          .read(registerStateNotifierProvider.notifier)
          .saveStep1(_emailCtrl.text, _passCtrl.text);
      final controller = ref.read(registerPageControllerProvider);
      await controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(r"^[\w.!#%&'*+/=?^_`{|}~-]+@[^\s@]+\.[^\s@]+$");
    if (!regex.hasMatch(value)) {
      return AppLocalizations.of(context)!.auth_error_invalid_email;
    }
    if (_emailError != null) return _emailError;
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return null;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
    final hasDigit = RegExp(r'\d').hasMatch(value);
    if (value.length < 8 || !hasUpper || !hasDigit) {
      return AppLocalizations.of(context)!.auth_error_weak_password;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isValid =
        _validateEmail(_emailCtrl.text) == null &&
        _validatePassword(_passCtrl.text) == null &&
        _emailCtrl.text.isNotEmpty &&
        _passCtrl.text.isNotEmpty;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                labelText: loc.email_hint,
                errorText: _emailError,
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {
                _emailError = null;
              }),
              validator: _validateEmail,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passCtrl,
              decoration: InputDecoration(
                labelText: loc.password_hint,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: _toggle,
                ),
              ),
              obscureText: _obscure,
              onChanged: (_) => setState(() {}),
              validator: _validatePassword,
            ),
            const SizedBox(height: 8),
            PasswordStrengthIndicator(password: _passCtrl.text),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isValid ? _continue : null,
              child: Text(loc.continue_button),
            ),
          ],
        ),
      ),
    );
  }
}
