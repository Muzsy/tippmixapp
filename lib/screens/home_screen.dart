import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/widgets/my_bottom_navigation_bar.dart';
import 'package:tippmixapp/widgets/app_drawer.dart';
import 'package:tippmixapp/widgets/notification_bell_widget.dart';
import 'package:tippmixapp/widgets/home/user_stats_header.dart';
import 'package:tippmixapp/widgets/home/home_tile_daily_bonus.dart';
import 'package:tippmixapp/widgets/home/home_tile_educational_tip.dart';
import 'package:tippmixapp/widgets/home/home_tile_ai_tip.dart';
import 'package:tippmixapp/widgets/home/home_tile_top_tipster.dart';
import 'package:tippmixapp/widgets/home/home_tile_badge_earned.dart';
import 'package:tippmixapp/widgets/home/home_tile_challenge_prompt.dart';
import 'package:tippmixapp/widgets/home/home_tile_feed_activity.dart';
import 'package:tippmixapp/providers/leaderboard_provider.dart';
import 'package:tippmixapp/providers/stats_provider.dart';
import 'package:tippmixapp/services/ai_tip_provider.dart';
import 'package:tippmixapp/services/badge_service.dart';
import 'package:tippmixapp/services/challenge_service.dart';
import 'package:tippmixapp/models/earned_badge_model.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/routes/app_route.dart';
import 'package:tippmixapp/providers/feed_provider.dart';
import 'package:tippmixapp/models/feed_model.dart';

/// Whether the daily bonus tile should be shown on the home screen.
final dailyBonusAvailableProvider = StateProvider<bool>((ref) => false);

/// Whether a new badge tile should be shown on the home screen.
/// Provides the latest earned badge of the user if any.
final latestBadgeProvider = FutureProvider<EarnedBadgeModel?>((ref) async {
  final uid = ref.watch(authProvider).user?.id;
  if (uid == null) return null;
  return BadgeService().getLatestBadge(uid);
});

/// Provides today's AI tip if available.
final aiTipFutureProvider = FutureProvider<AiTip?>((ref) async {
  return AiTipProvider().getDailyTip();
});

/// Provides active challenges for the current user.
final activeChallengesProvider =
    FutureProvider<List<ChallengeModel>>((ref) async {
  final uid = ref.watch(authProvider).user?.id;
  if (uid == null) return <ChallengeModel>[];
  return ChallengeService().fetchActiveChallenges(uid);
});

/// Provides the latest feed activity if available.
final latestFeedActivityProvider = FutureProvider<FeedModel?>((ref) async {
  final service = ref.watch(feedServiceProvider);
  return service.fetchLatestEntry();
});

/// Home screen root. In tests the [showStats] flag can force the
/// statistics header to appear independent of routing.
class HomeScreen extends ConsumerWidget {
  final GoRouterState? state;
  final Widget? child;
  final bool showStats;

  const HomeScreen({
    this.state,
    this.child,
    this.showStats = false,
    super.key,
  });

  // --- private helpers -----------------------------------------------------

  bool _isRootRoute() => state?.name == AppRoute.home.name;

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    // In tests showGrid can be forced by the [showStats] flag so that the
    // header + tiles render without depending on routing.
    final showGrid = showStats || _isRootRoute();

    if (!showGrid) return child ?? const SizedBox.shrink();

    final statsAsync = ref.watch(userStatsProvider);

    // --- build tile list ---------------------------------------------------
    final tiles = <Widget>[const HomeTileEducationalTip()];

    final aiTip = ref.watch(aiTipFutureProvider).asData?.value;
    final topTipster = ref.watch(topTipsterProvider).asData?.value;
    final feedActivity = ref.watch(latestFeedActivityProvider).asData?.value;
    final challenges = ref.watch(activeChallengesProvider).asData?.value;

    if (aiTip != null) tiles.add(HomeTileAiTip(tip: aiTip));
    if (topTipster != null) tiles.add(HomeTileTopTipster(stats: topTipster));
    if (feedActivity != null) {
      tiles.add(HomeTileFeedActivity(
        entry: feedActivity,
        onTap: () => context.goNamed(AppRoute.events.name),
      ));
    }
    if (challenges != null && challenges.isNotEmpty) {
      tiles.add(HomeTileChallengePrompt(
        challenge: challenges.first,
        onAccept: () => context.goNamed(AppRoute.createTicket.name),
      ));
    }
    if (ref.watch(dailyBonusAvailableProvider)) {
      tiles.add(const HomeTileDailyBonus());
    }

    final earned = ref.watch(latestBadgeProvider).asData?.value;
    if (earned != null &&
        DateTime.now().difference(earned.timestamp).inDays <= 3) {
      tiles.add(HomeTileBadgeEarned(
        badge: earned,
        onTap: () => context.goNamed(AppRoute.badges.name),
      ));
    }

    // --- assemble layout ---------------------------------------------------
    return statsAsync.when(
      data: (stats) => Column(
        children: [
          // Header *only* here when [showStats] is *false* and we are on root.
          if (!showStats && _isRootRoute()) UserStatsHeader(stats: stats),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              children: tiles,
            ),
          ),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // --- build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final body = _buildBody(context, ref);

    // Determine current route path for dynamic title.
    final currentPath = state?.uri.path ?? '/';
    final titles = <String, String>{
      '/': 'TippmixApp',
      '/feed': loc.feed_screen_title,
      '/profile': loc.profile_title,
      '/my-tickets': loc.my_tickets_title,
      '/badges': loc.badgeScreenTitle,
      '/rewards': loc.rewardTitle,
      '/notifications': loc.notificationTitle,
      '/settings': loc.settings_title,
    };
    final titleText = titles[currentPath] ?? loc.home_title;

    // When tests set [showStats] we render a bare column without AppBar etc.
    if (showStats) {
      final stats = ref.watch(userStatsProvider).asData?.value;
      return Column(
        children: [
          if (stats != null) UserStatsHeader(stats: stats),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
        title: Text(titleText),
        actions: const [NotificationBellWidget()],
      ),
      drawer: const AppDrawer(),
      body: body,
      bottomNavigationBar: const MyBottomNavigationBar(),
    );
  }
}
