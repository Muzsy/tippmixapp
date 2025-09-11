import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';

class OtpPromptScreen extends ConsumerStatefulWidget {
  final String email;
  const OtpPromptScreen({super.key, required this.email});

  @override
  ConsumerState<OtpPromptScreen> createState() => _OtpPromptScreenState();
}

class _OtpPromptScreenState extends ConsumerState<OtpPromptScreen> {
  final TextEditingController _ctrl = TextEditingController();
  String? _error;
  bool _cooldown = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _ctrl.text.trim();
    final err = await ref.read(authProvider.notifier).requestVerifyEmailOtp(widget.email, code);
    if (!mounted) return;
    if (err != null) {
      setState(() => _error = AppLocalizations.of(context)!.otp_error_invalid);
    } else {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _resend() async {
    if (_cooldown) return;
    setState(() => _cooldown = true);
    await ref.read(authProvider.notifier).resendSignupOtp(widget.email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.emailVerify_sent)),
    );
    await Future.delayed(const Duration(seconds: 30));
    if (mounted) setState(() => _cooldown = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.otp_prompt_title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // You can show the destination email if needed.
            // Using existing localized strings to avoid missing getters.
            // Example: "Ellenőrző email elküldve!" (emailVerify_sent)
            Text(AppLocalizations.of(context)!.emailVerify_sent),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                labelText: loc.otp_enter_code,
                errorText: _error,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _verify, child: Text(loc.btnContinue)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _cooldown ? null : _resend,
              child: Text(loc.emailVerify_resend),
            ),
          ],
        ),
      ),
    );
  }
}
