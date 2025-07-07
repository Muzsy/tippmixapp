import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../services/experiment_service.dart';
import '../../services/analytics_service.dart';
import 'login_form.dart';
import 'login_screen_variant_b.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: ref.read(experimentServiceProvider).getLoginVariant(),
      builder: (context, snapshot) {
        final variant = snapshot.data ?? 'A';
        ref
            .read(analyticsServiceProvider)
            .logLoginVariantExposed(variant);
        if (variant == 'B') {
          return LoginScreenVariantB(variant: variant);
        }
        return _LoginScreenBase(variant: variant);
      },
    );
  }
}

class _LoginScreenBase extends StatelessWidget {
  final String variant;
  const _LoginScreenBase({required this.variant});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.login_title)),
      body: Center(child: LoginForm(variant: variant)),
    );
  }
}
