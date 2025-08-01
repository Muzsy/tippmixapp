import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/register_state_notifier.dart';

class RegisterStep2Form extends ConsumerStatefulWidget {
  const RegisterStep2Form({super.key});

  @override
  ConsumerState<RegisterStep2Form> createState() => _RegisterStep2FormState();
}

class _RegisterStep2FormState extends ConsumerState<RegisterStep2Form> {
  final _formKey = GlobalKey<FormState>();
  final _nickCtrl = TextEditingController();
  DateTime? _birthDate;
  bool _consent = false;
  bool _showDateError = false;
  bool _showConsentError = false;
  Timer? _debounce;
  String? _nickError;

  @override
  void dispose() {
    _nickCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (date != null) {
      setState(() {
        _birthDate = date;
        _showDateError = false;
      });
    }
  }

  Future<void> _onNextPressed() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || _birthDate == null || !_consent) {
      setState(() {
        _showDateError = _birthDate == null;
        _showConsentError = !_consent;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hiányos adatok, kérlek töltsd ki!')),
      );
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final auth = ref.read(authServiceProvider);
      final unique = await auth.validateNicknameUnique(_nickCtrl.text);
      if (!unique) {
        setState(() {
          _nickError = AppLocalizations.of(context)!.auth_error_nickname_taken;
        });
        return;
      }
      ref
          .read(registerStateNotifierProvider.notifier)
          .saveStep2(_nickCtrl.text, _birthDate!, _consent);
      final controller = ref.read(registerPageControllerProvider);
      await controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  String? _validateNick(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 3 || value.length > 20) {
      return AppLocalizations.of(context)!.auth_error_invalid_nickname;
    }
    if (_nickError != null) return _nickError;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              key: const Key('nicknameField'),
              controller: _nickCtrl,
              decoration: InputDecoration(
                labelText: loc.profile_nickname,
                errorText: _nickError,
              ),
              onChanged: (_) => setState(() {
                _nickError = null;
              }),
              validator: _validateNick,
            ),
            const SizedBox(height: 8),
            InkWell(
              key: const Key('birthDateField'),
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: loc.dob_hint,
                  errorText: _showDateError
                      ? loc.auth_error_invalid_date
                      : null,
                ),
                child: Text(
                  _birthDate == null
                      ? ''
                      : MaterialLocalizations.of(
                          context,
                        ).formatMediumDate(_birthDate!),
                ),
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _consent,
              onChanged: (v) => setState(() {
                _consent = v ?? false;
                if (_consent) _showConsentError = false;
              }),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(loc.gdpr_consent),
              subtitle: _showConsentError
                  ? Text(
                      loc.gdpr_required_error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    final controller = ref.read(registerPageControllerProvider);
                    await controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Text(loc.back_button),
                ),
                ElevatedButton(
                  onPressed: _onNextPressed,
                  child: Text(loc.continue_button),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
