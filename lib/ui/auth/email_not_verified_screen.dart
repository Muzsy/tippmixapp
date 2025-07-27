import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailNotVerifiedScreen extends StatefulWidget {
  const EmailNotVerifiedScreen({super.key});
  @override
  State<EmailNotVerifiedScreen> createState() => _EmailNotVerifiedScreenState();
}

class _EmailNotVerifiedScreenState extends State<EmailNotVerifiedScreen> {
  bool _sending = false;
  bool _reloading = false;

  Future<void> _resend() async {
    setState(() => _sending = true);
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verifikációs e‑mail elküldve.')),
    );
  }

  Future<void> _refresh() async {
    setState(() => _reloading = true);
    await FirebaseAuth.instance.currentUser?.reload();
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
              child: _sending ? const CircularProgressIndicator() : const Text('Újra küldés'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _reloading ? null : _refresh,
              child: _reloading ? const CircularProgressIndicator() : const Text('Megerősítettem'),
            ),
          ],
        ),
      ),
    );
  }
}
