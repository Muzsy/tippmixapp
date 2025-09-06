import 'package:flutter/material.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import '../../services/security_service.dart';

class OtpPromptScreen extends StatefulWidget {
  final SecurityService service;
  const OtpPromptScreen({super.key, required this.service});

  @override
  State<OtpPromptScreen> createState() => _OtpPromptScreenState();
}

class _OtpPromptScreenState extends State<OtpPromptScreen> {
  final TextEditingController _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

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
              controller: _ctrl,
              decoration: InputDecoration(
                labelText: loc.otp_enter_code,
                errorText: _error,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final ok = await widget.service.verifyOtp(_ctrl.text);
                if (!context.mounted) return;
                final l = AppLocalizations.of(context)!;
                if (!ok) {
                  setState(() => _error = l.otp_error_invalid);
                } else {
                  Navigator.of(context).pop(true);
                }
              },
              child: Text(loc.otp_prompt_title),
            ),
          ],
        ),
      ),
    );
  }
}
