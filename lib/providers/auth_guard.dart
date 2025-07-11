import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/login_required_dialog.dart';
import 'auth_provider.dart';
import '../routes/app_route.dart';
import 'package:go_router/go_router.dart';

/// Wraps content that requires an authenticated user.
class RequireAuth extends ConsumerWidget {
  final Widget child;
  const RequireAuth({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(authProvider.notifier);
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
    if (!notifier.isEmailVerified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.goNamed(AppRoute.emailNotVerified.name);
        }
      });
      return const SizedBox.shrink();
    }
    return child;
  }
}
