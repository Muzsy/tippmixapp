// Header widget used on the profile screen.
// Displays the user's avatar, name and e-mail when authenticated.
// If the user is not signed in a short call-to-action is shown instead.
import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Header section of the profile screen.
///
/// Shows the avatar, display name and e-mail address of the authenticated user
/// or a simple login call-to-action when the user is null.
class ProfileHeader extends StatelessWidget {
  final User? user;

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
          CircleAvatar(
            radius: 30,
            backgroundImage: user!.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : null,
            child: user!.photoURL == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Prefer nickname from Firestore as primary display
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final data = snapshot.data?.data();
                    final nickname = (data?['nickname'] as String?)?.trim();
                    final fallback = (user!.displayName?.isNotEmpty ?? false)
                        ? user!.displayName!
                        : (user!.email ?? loc.profile_guest);
                    final display = (nickname != null && nickname.isNotEmpty)
                        ? nickname
                        : fallback;
                    return Text(display, style: Theme.of(context).textTheme.titleLarge);
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  user!.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
