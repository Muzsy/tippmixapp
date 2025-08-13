import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  const EmailField({
    super.key,
    required this.controller,
    this.focusNode,
    this.nextFocus,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Semantics(
      label: loc.email_hint,
      textField: true,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) => nextFocus?.requestFocus(),
        decoration: InputDecoration(labelText: loc.email_hint),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }
}
