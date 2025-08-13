import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import '../../providers/onboarding_provider.dart';
import '../../router.dart';
import '../../routes/app_route.dart';
import 'pages/onboarding_page1.dart';
import 'pages/onboarding_page2.dart';
import 'pages/onboarding_page3.dart';

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  late final PageController _controller;
  late DateTime _start;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _start = DateTime.now();
  }

  void _finish() {
    final duration = DateTime.now().difference(_start);
    ref.read(onboardingProvider.notifier).complete(duration);
    router.goNamed(AppRoute.home.name);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final page = ref.watch(onboardingProvider);

    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (i) => ref.read(onboardingProvider.notifier).setPage(i),
        children: const [
          OnboardingPage1(),
          OnboardingPage2(),
          OnboardingPage3(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(onPressed: _finish, child: Text(loc.onboarding_skip)),
            Row(
              children: List.generate(3, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == page ? Colors.blue : Colors.grey,
                  ),
                );
              }),
            ),
            TextButton(
              onPressed: () {
                if (page == 2) {
                  _finish();
                } else {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Text(
                page == 2 ? loc.onboarding_done : loc.onboarding_next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
