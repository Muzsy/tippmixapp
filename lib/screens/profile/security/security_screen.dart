import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import '../../../routes/app_route.dart';
import '../../../services/security_service.dart';
import '../../../models/two_factor_type.dart';

class SecurityScreen extends StatefulWidget {
  final SecurityService service;
  const SecurityScreen({super.key, required this.service});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _enabled = widget.service.status;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.security_title)),
      body: SwitchListTile(
        title: Text(_enabled ? loc.disable_two_factor : loc.enable_two_factor),
        value: _enabled,
        onChanged: (v) async {
          if (v) {
            final ok = await widget.service.enable(TwoFactorType.sms);
            if (!context.mounted) return;
            if (ok) context.pushNamed(AppRoute.twoFactorWizard.name);
          } else {
            await widget.service.disable();
            if (!context.mounted) return;
          }
          setState(() => _enabled = widget.service.status);
        },
      ),
    );
  }
}
