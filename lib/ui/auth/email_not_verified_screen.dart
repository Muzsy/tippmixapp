import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class EmailNotVerifiedScreen extends ConsumerStatefulWidget {
  const EmailNotVerifiedScreen({super.key});
  @override
  ConsumerState<EmailNotVerifiedScreen> createState() => _EmailNotVerifiedScreenState();
}

class _EmailNotVerifiedScreenState extends ConsumerState<EmailNotVerifiedScreen> {
  bool _sending = false;
  bool _reloading = false;

  Future<void> _resend() async {
    setState(() => _sending = true);
    await ref.read(authProvider.notifier).sendEmailVerification();
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verifikációs e‑mail elküldve.')),
    );
  }

  Future<void> _refresh() async {
    setState(() => _reloading = true);
    await ref.read(authProvider.notifier).logout();
    // Itt egyszerű visszalépést használunk: a Splash/Router állapot alapján úgyis
    // a megfelelő képernyőre kerül a felhasználó belépés után.
    if (!mounted) return;
    setState(() => _reloading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E‑mail megerősítése szükséges')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'A fiókod aktiválásához erősítsd meg az e‑mail‑címedet. A levélben található linkre kattintva térj vissza az alkalmazásba.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _sending ? null : _resend,
              child: _sending
                  ? const CircularProgressIndicator()
                  : const Text('Újra küldés'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _reloading ? null : _refresh,
              child: _reloading
                  ? const CircularProgressIndicator()
                  : const Text('Megerősítettem'),
            ),
          ],
        ),
      ),
    );
  }
}
