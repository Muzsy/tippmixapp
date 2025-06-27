import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../services/challenge_service.dart';

/// Tile displaying an active challenge for the user.
class HomeTileChallengePrompt extends ConsumerWidget {
  final ChallengeModel challenge;
  final VoidCallback? onAccept;

  const HomeTileChallengePrompt({
    super.key,
    required this.challenge,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      child: InkWell(
        onTap: onAccept,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.flag, size: 48),
              const SizedBox(height: 8),
              Text(loc.home_tile_challenge_title, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(_description(loc), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onAccept,
                child: Text(loc.home_tile_challenge_cta_accept),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _description(AppLocalizations loc) {
    switch (challenge.type) {
      case ChallengeType.friend:
        return loc.home_tile_challenge_friend_description(
            challenge.username ?? '');
      case ChallengeType.daily:
      case ChallengeType.weekly:
        return loc.home_tile_challenge_daily_description;
    }
  }
}
