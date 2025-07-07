import 'package:flutter/material.dart';

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.verified,
        color: Theme.of(context).colorScheme.primary, size: 16);
  }
}
