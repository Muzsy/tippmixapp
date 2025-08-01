import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../screens/auth/login_screen.dart';
// HomeScreen-import kivezetve – a ShellRoute hozza be
import '../../providers/auth_provider.dart';
import 'email_not_verified_screen.dart';

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
      return const EmailNotVerifiedScreen();
    }
    // A ShellRoute már tartalmazza a Home-héjat; itt csak átirányítunk
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go('/feed');
    });
    return const SizedBox.shrink();
  }
}
