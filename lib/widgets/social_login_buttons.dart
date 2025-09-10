import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_colors_presets.dart';
import '../services/auth_service.dart';

class SocialLoginButtons extends ConsumerWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    // Supabase módban is láthatóak a gombok (OAuth bekötve az adapterben)
    final colors =
        Theme.of(context).extension<BrandColors>() ?? brandColorsLight;
    final auth = ref.read(authServiceProvider);

    final messenger = ScaffoldMessenger.of(context);
    final buttons = <Widget>[
      _SocialLoginButton(
        key: const Key("google_login_button"),
        label: loc.google_login,
        icon: Icons.g_mobiledata,
        color: colors.google,
        onPressed: () async {
          try {
            await auth.signInWithGoogle();
          } on AuthServiceException catch (e) {
            if (!context.mounted) return;
            messenger.showSnackBar(
              SnackBar(content: Text(_mapError(context, e.code))),
            );
          }
        },
      ),
      _SocialLoginButton(
        key: const Key("facebook_login_button"),
        label: loc.facebook_login,
        icon: Icons.facebook,
        color: colors.facebook,
        onPressed: () async {
          try {
            await auth.signInWithFacebook();
          } on AuthServiceException catch (e) {
            if (!context.mounted) return;
            messenger.showSnackBar(
              SnackBar(content: Text(_mapError(context, e.code))),
            );
          }
        },
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
          icon: Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
          label: Text(label),
          style: ElevatedButton.styleFrom(backgroundColor: color),
        ),
      ),
    );
  }
}

String _mapError(BuildContext context, String code) {
  final loc = AppLocalizations.of(context)!;
  if (code == 'auth/facebook-cancelled') {
    return loc.dialog_cancel;
  }
  return loc.auth_error_unknown;
}
