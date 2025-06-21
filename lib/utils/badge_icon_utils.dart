import 'package:flutter/material.dart';

/// Returns the matching [IconData] for a badge icon name.
IconData getIconForBadge(String iconName) {
  switch (iconName) {
    case 'star':
      return Icons.star;
    case 'whatshot':
      return Icons.whatshot;
    case 'track_changes':
      return Icons.track_changes;
    case 'nights_stay':
      return Icons.nights_stay;
    case 'bolt':
      return Icons.bolt;
    default:
      return Icons.emoji_events;
  }
}
