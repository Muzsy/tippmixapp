import 'package:flutter/material.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

class ComposerBar extends StatelessWidget {
  const ComposerBar({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.enabled = true,
    required this.focusNode,
  });

  final TextEditingController controller;
  final Future<void> Function()? onSubmit;
  final bool enabled;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              focusNode: focusNode,
              decoration: InputDecoration(hintText: loc.dialog_comment_title),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            tooltip: loc.dialog_send,
            onPressed: enabled ? onSubmit : null,
          ),
        ],
      ),
    );
  }
}
