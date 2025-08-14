import 'package:flutter/material.dart';
import 'guest_promo_tile.dart';
import 'home/user_stats_header.dart';

// The auth provider interface may differ in the project; this typedef
// keeps the build compiling by delegating login state checks.
typedef IsLoggedIn = bool Function();

class HomeProfileHeader extends StatelessWidget {
  final IsLoggedIn isLoggedIn;
  final VoidCallback? onLoginTap;
  final VoidCallback? onRegisterTap;
  const HomeProfileHeader({
    super.key,
    required this.isLoggedIn,
    this.onLoginTap,
    this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn()) {
      return GuestPromoTile(
        onLoginTap: onLoginTap,
        onRegisterTap: onRegisterTap,
      );
    }
    // Logged-in view: reuse the existing UserStatsHeader
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: UserStatsHeader(),
    );
  }
}
