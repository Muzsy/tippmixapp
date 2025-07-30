import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/splash_controller.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(splashControllerProvider, (previous, next) {
      next.whenData((route) => context.goNamed(route.name));
    });
    ref.watch(splashControllerProvider);
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
