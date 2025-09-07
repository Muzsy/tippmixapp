import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_route.dart';
import '../../widgets/cooldown_button.dart';

class EmailNotVerifiedScreen extends ConsumerWidget {
  const EmailNotVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.emailVerify_title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_unread_outlined, size: 96),
            const SizedBox(height: 24),
            Text(loc.emailVerify_description, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            CooldownButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).sendEmailVerification();
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(loc.emailVerify_sent)));
                }
              },
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.goNamed(AppRoute.login.name);
                }
              },
              child: Text(loc.emailVerify_exit),
            ),
          ],
        ),
      ),
    );
  }
}
