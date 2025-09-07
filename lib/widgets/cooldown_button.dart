import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

class CooldownButton extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final Duration cooldown;
  const CooldownButton({
    super.key,
    required this.onPressed,
    this.cooldown = const Duration(seconds: 60),
  });

  @override
  State<CooldownButton> createState() => _CooldownButtonState();
}

class _CooldownButtonState extends State<CooldownButton> {
  int _remaining = 0;
  Timer? _timer;

  bool get _disabled => _remaining > 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handle() async {
    await widget.onPressed?.call();
    setState(() {
      _remaining = widget.cooldown.inSeconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining == 1) {
        timer.cancel();
        setState(() => _remaining = 0);
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final label = _disabled
        ? '${loc.emailVerify_resend} ($_remaining)'
        : loc.emailVerify_resend;
    return ElevatedButton(
      onPressed: _disabled ? null : _handle,
      child: Text(label),
    );
  }
}
