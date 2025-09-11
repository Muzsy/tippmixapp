import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import '../controllers/register_step1_viewmodel.dart';
import '../providers/register_state_notifier.dart';
import '../providers/hibp_service_provider.dart';
// Recaptcha and AuthRepository removed in Supabase-only mode
import '../services/analytics_service.dart';
import '../widgets/password_strength_indicator.dart';
import '../helpers/validators.dart';

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
    final hibp = ref.read(hibpServiceProvider);
    final analytics = ref.read(analyticsServiceProvider);
    if (await hibp.isPasswordPwned(_passCtrl.text)) {
      analytics.logRegPasswordPwned();
      // ignore: use_build_context_synchronously
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        // ignore: use_build_context_synchronously
        SnackBar(
          // ignore: use_build_context_synchronously
          content: Text(AppLocalizations.of(context)!.password_pwned_error),
        ),
      );
      return;
    }
    // Recaptcha skipped in Supabase-only mode
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      // Email availability check skipped in Supabase-only mode
      ref
          .read(registerStateNotifierProvider.notifier)
          .saveStep1(_emailCtrl.text, _passCtrl.text);
      final controller = ref.read(registerPageControllerProvider);
      try {
        if (!mounted) return;
        await controller.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.unknown_error_try_again,
            ),
          ),
        );
      }
    });
  }

  String? _validateEmail(String? value) {
    final key = validateEmail(value);
    if (key != null) {
      return AppLocalizations.of(context)!.errorInvalidEmail;
    }
    if (_emailError != null) return _emailError;
    return null;
  }

  String? _validatePassword(String? value) {
    final key = validatePassword(value);
    if (key != null) {
      return AppLocalizations.of(context)!.errorWeakPassword;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    ref.listen<RegisterStep1State>(registerStep1ViewModelProvider, (
      prev,
      next,
    ) {
      if (next == RegisterStep1State.checkingEmail) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text(loc.loaderCheckingEmail),
              ],
            ),
          ),
        );
      } else {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      }
    });
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
              key: const Key('emailField'),
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
              key: const Key('passwordField'),
              controller: _passCtrl,
              decoration: InputDecoration(
                labelText: loc.password_hint,
                suffixIcon: IconButton(
                  tooltip: loc.profile_toggle_visibility,
                  icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
                    semanticLabel: loc.profile_toggle_visibility,
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
              key: const Key('continueStep1'),
              onPressed: isValid ? _continue : null,
              child: Text(loc.continue_button),
            ),
          ],
        ),
      ),
    );
  }
}
