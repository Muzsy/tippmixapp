import 'package:flutter/material.dart';
import '../../widgets/promo_panel.dart';
import 'login_form.dart';

class LoginScreenVariantB extends StatelessWidget {
  final String variant;
  const LoginScreenVariantB({super.key, required this.variant});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final form = Center(child: LoginForm(variant: variant));
    final promo = const PromoPanel();
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: isWide
          ? Row(
              children: [
                Expanded(child: form),
                Expanded(child: promo),
              ],
            )
          : ListView(
              children: [
                form,
                promo,
              ],
            ),
    );
  }
}
