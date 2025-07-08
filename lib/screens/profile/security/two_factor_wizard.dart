import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/security_service.dart';

class TwoFactorWizard extends StatefulWidget {
  final SecurityService service;
  const TwoFactorWizard({super.key, required this.service});

  @override
  State<TwoFactorWizard> createState() => _TwoFactorWizardState();
}

class _TwoFactorWizardState extends State<TwoFactorWizard> {
  final TextEditingController _otp = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.otp_prompt_title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _otp,
              decoration: InputDecoration(labelText: loc.otp_enter_code),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final ok = await widget.service.verifyOtp(_otp.text);
                if (!context.mounted) return;
                final l = AppLocalizations.of(context)!;
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.otp_error_invalid)),
                  );
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text(loc.otp_prompt_title),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }
}
