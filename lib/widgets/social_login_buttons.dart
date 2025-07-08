import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../theme/brand_colors.dart';

class SocialLoginButtons extends ConsumerWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<BrandColors>()!;
    final auth = ref.read(authServiceProvider);

    final buttons = <Widget>[
      _SocialLoginButton(
        key: const Key('google_login_button'),
        label: loc.google_login,
        icon: Icons.g_mobiledata,
        color: colors.google,
        onPressed: auth.signInWithGoogle,
      ),
      _SocialLoginButton(
        key: const Key('facebook_login_button'),
        label: loc.facebook_login,
        icon: Icons.facebook,
        color: colors.facebook,
        onPressed: auth.signInWithFacebook,
      ),
    ];

    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      buttons.insert(
        1,
        _SocialLoginButton(
          key: const Key('apple_login_button'),
          label: loc.apple_login,
          icon: Icons.apple,
          color: colors.apple,
          onPressed: auth.signInWithApple,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons,
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          label: Text(label),
          style: ElevatedButton.styleFrom(backgroundColor: color),
        ),
      ),
    );
  }
}
