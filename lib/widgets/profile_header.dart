// Header widget used on the profile screen.
// Displays the user's avatar, name and e-mail when authenticated.
// If the user is not signed in a short call-to-action is shown instead.
import 'package:flutter/material.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:firebase_auth/firebase_auth.dart' show User;

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
                // Prefer nickname from backend profile as primary display
                Builder(
                  builder: (context) {
                    final useSupabase = dotenv.env['USE_SUPABASE']?.toLowerCase() == 'true';
                    if (useSupabase) {
                      return FutureBuilder<List<Map<String, dynamic>>>(
                        future: sb.Supabase.instance.client
                            .from('profiles')
                            .select('nickname')
                            .eq('id', user!.uid)
                            .limit(1),
                        builder: (context, snap) {
                          final nickname = ((snap.data?.isNotEmpty ?? false)
                                  ? snap.data!.first['nickname'] as String?
                                  : null)
                              ?.trim();
                          final fallback = (user!.displayName?.isNotEmpty ?? false)
                              ? user!.displayName!
                              : (user!.email ?? loc.profile_guest);
                          final display = (nickname != null && nickname.isNotEmpty)
                              ? nickname
                              : fallback;
                          return Text(display, style: Theme.of(context).textTheme.titleLarge);
                        },
                      );
                    }
                    // Firebase fallback remains if Supabase mode off
                    return Text(
                      (user!.displayName?.isNotEmpty ?? false)
                          ? user!.displayName!
                          : (user!.email ?? loc.profile_guest),
                      style: Theme.of(context).textTheme.titleLarge,
                    );
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
