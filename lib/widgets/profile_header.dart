// Header widget used on the profile screen.
// Displays the user's avatar, name and e-mail when authenticated.
// If the user is not signed in a short call-to-action is shown instead.
import 'package:flutter/material.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import '../models/user.dart' as app_user;

/// Header section of the profile screen.
///
/// Shows the avatar, display name and e-mail address of the authenticated user
/// or a simple login call-to-action when the user is null.
class ProfileHeader extends StatelessWidget {
  final app_user.User? user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (user == null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.person, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                loc.profile_guest,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const CircleAvatar(radius: 30, child: Icon(Icons.person)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (user!.displayName.isNotEmpty)
                      ? user!.displayName
                      : (user!.email.isNotEmpty ? user!.email : loc.profile_guest),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(user!.email, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
