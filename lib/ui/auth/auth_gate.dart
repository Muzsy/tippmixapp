import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../screens/auth/login_screen.dart';
// HomeScreen-import kivezetve – a ShellRoute hozza be
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../routes/app_route.dart';

/// Gate widget deciding whether to show the login, verification
/// prompt or the home screen based on auth state.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);
    final notifier = ref.read(authProvider.notifier);
    final user = state.user;
    if (user == null) {
      return const LoginScreen();
    }
    if (!notifier.isEmailVerified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.goNamed(AppRoute.emailNotVerified.name);
        }
      });
      return const SizedBox.shrink();
    }
    // Bejelentkezett és verifikált felhasználó → maradunk a '/' útvonalon,
    // a ShellRoute + HomeScreen héj megjeleníti a fő (csempés) kezdőképernyőt.
    return const SizedBox.shrink();
  }
}
