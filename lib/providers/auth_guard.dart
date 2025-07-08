import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/login_required_dialog.dart';
import 'auth_provider.dart';

/// Wraps content that requires an authenticated user.
class RequireAuth extends ConsumerWidget {
  final Widget child;
  const RequireAuth({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authProvider).user?.id;
    if (uid == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (_) => const LoginRequiredDialog(),
          );
        }
      });
      return const SizedBox.shrink();
    }
    return child;
  }
}
