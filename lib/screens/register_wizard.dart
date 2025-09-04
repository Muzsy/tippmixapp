import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import '../providers/register_state_notifier.dart';
import 'register_step1_form.dart';
import 'register_step2_form.dart';
import 'register_step3_form.dart';
import 'package:cloud_functions/cloud_functions.dart';

class RegisterWizard extends ConsumerStatefulWidget {
  final FirebaseFunctions? functions;
  const RegisterWizard({super.key, this.functions});

  @override
  ConsumerState<RegisterWizard> createState() => _RegisterWizardState();
}

class _RegisterWizardState extends ConsumerState<RegisterWizard> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void deactivate() {
    // Állapot törlése, hogy a következő regisztráció tiszta legyen
    ref.read(registerStateNotifierProvider.notifier).reset();
    super.deactivate();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return ProviderScope(
      overrides: [
        registerPageControllerProvider.overrideWithValue(_pageController),
      ],
      child: Scaffold(
        key: const Key('registerPage'),
        appBar: AppBar(title: Text(loc.register_tab)),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const RegisterStep1Form(),
            RegisterStep2Form(functions: widget.functions),
            const RegisterStep3Form(),
          ],
        ),
      ),
    );
  }
}
