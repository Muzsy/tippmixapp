import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../services/analytics_service.dart';
import 'login_form.dart';
import '../../providers/auth_state_provider.dart';
import '../../routes/app_route.dart';
import 'package:go_router/go_router.dart';
import '../../models/user.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const variant = 'A';
    ref.read(analyticsServiceProvider).logLoginVariantExposed(variant);
    return const _LoginScreenBase(variant: variant);
  }
}

class _LoginScreenBase extends ConsumerWidget {
  final String variant;
  const _LoginScreenBase({required this.variant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
      next.whenData((user) {
        if (user != null && context.mounted) {
          context.goNamed(AppRoute.home.name);
        }
      });
    });
    return Scaffold(
      appBar: AppBar(title: Text(loc.login_title)),
      body: Center(child: LoginForm(variant: variant)),
    );
  }
}
