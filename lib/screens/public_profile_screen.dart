import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../constants.dart';
import '../l10n/app_localizations.dart';

/// Displays another user's profile applying privacy rules.
class PublicProfileScreen extends StatelessWidget {
  final UserModel user;

  const PublicProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final fields = {
      'city': loc.profile_city,
      'country': loc.profile_country,
      'friends': loc.profile_friends,
      'favoriteSports': loc.profile_favorite_sports,
      'favoriteTeams': loc.profile_favorite_teams,
    };
    return Scaffold(
      appBar: AppBar(title: Text(loc.profile_title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             CircleAvatar(
              radius: 40,
              backgroundImage: user.avatarUrl.isNotEmpty
                  ? (user.avatarUrl.startsWith('http')
                      ? NetworkImage(user.avatarUrl)
                      : AssetImage(user.avatarUrl) as ImageProvider)
                  : null,
              child: user.avatarUrl.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(height: 12),
            Text('${loc.profile_nickname}: ${user.nickname}',
                style: const TextStyle(fontSize: 16)),
            if (!user.isPrivate) ...[
              for (final entry in fields.entries)
                if (user.fieldVisibility[entry.key] ?? false) ...[
                  const SizedBox(height: 8),
                  Text(entry.value, style: const TextStyle(fontSize: 14)),
                ],
            ],
          ],
        ),
      ),
    );
  }
}
