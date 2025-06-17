import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/widgets/auth/login_form.dart';
import 'package:tippmixapp/widgets/auth/register_form.dart';
import 'package:tippmixapp/controllers/auth_controller.dart';

class LoginRegisterScreen extends StatelessWidget {
  const LoginRegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLogin = useState(true);
    final emailCtrl = useTextEditingController();
    final passCtrl = useTextEditingController();
    final confirmCtrl = useTextEditingController();

    ref.listen(authControllerProvider, (prev, next) {
      next.whenOrNull(data: (user) {
        if (user != null) {
          context.go('/');
        }
      });
    });

    final loc = AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(loc.login_title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text(loc.login_tab),
                  selected: isLogin.value,
                  onSelected: (_) => isLogin.value = true,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(loc.register_tab),
                  selected: !isLogin.value,
                  onSelected: (_) => isLogin.value = false,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: isLogin.value
                    ? LoginForm(
                        emailController: emailCtrl,
                        passwordController: passCtrl,
                      )
                    : RegisterForm(
                        emailController: emailCtrl,
                        passwordController: passCtrl,
                        confirmController: confirmCtrl,
                      ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.login),
              label: Text(loc.google_login),
            ),
          ],
        ),
      ),
    );
  }
}
}
