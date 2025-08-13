import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback? onSubmit;
  const PasswordField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Semantics(
      label: loc.password_hint,
      textField: true,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => onSubmit?.call(),
        decoration: InputDecoration(labelText: loc.password_hint),
        obscureText: true,
      ),
    );
  }
}
