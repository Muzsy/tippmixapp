import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/register_state_notifier.dart';
import 'register_step1_form.dart';
import 'register_step2_form.dart';

class RegisterWizard extends ConsumerWidget {
  const RegisterWizard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(registerPageControllerProvider);
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.register_tab)),
      body: PageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          RegisterStep1Form(),
          RegisterStep2Form(),
          Center(child: Text('Step 3')), // placeholder
        ],
      ),
    );
  }
}
