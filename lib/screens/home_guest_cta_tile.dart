import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../routes/app_route.dart';

/// Tile prompting guest users to log in or register.
class HomeGuestCtaTile extends StatelessWidget {
  const HomeGuestCtaTile({super.key});

  void _navigate(BuildContext context) {
    context.goNamed(AppRoute.login.name);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      child: InkWell(
        onTap: () => _navigate(context),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.login, size: 48),
              const SizedBox(height: 8),
              Text(loc.home_guest_message, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _navigate(context),
                child: Text(loc.login_button),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
