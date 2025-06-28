import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/widgets/my_bottom_navigation_bar.dart';
import 'package:tippmixapp/widgets/app_drawer.dart';
import '../widgets/notification_bell_widget.dart';
import '../widgets/home/user_stats_header.dart';
import '../widgets/home/home_tile_daily_bonus.dart';
import '../widgets/home/home_tile_educational_tip.dart';
import '../widgets/home/home_tile_ai_tip.dart';
import '../widgets/home/home_tile_top_tipster.dart';
import '../widgets/home/home_tile_badge_earned.dart';
import '../widgets/home/home_tile_challenge_prompt.dart';
import '../widgets/home/home_tile_feed_activity.dart';
import '../providers/leaderboard_provider.dart';
import '../providers/stats_provider.dart';
import '../services/ai_tip_provider.dart';
import '../services/badge_service.dart';
import '../services/challenge_service.dart';
import '../models/earned_badge_model.dart';
import '../providers/auth_provider.dart';
import '../routes/app_route.dart';
import '../providers/feed_provider.dart';
import '../models/feed_model.dart';

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

class HomeScreen extends ConsumerWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    // … HomeScreen build-metódusában …
    final showGrid = GoRouterState.of(context).location == '/';

    Widget body;
    if (showGrid) {
      final statsAsync = ref.watch(userStatsProvider);
      final tiles = <Widget>[];
      tiles.add(const HomeTileEducationalTip());
      final aiTip = ref.watch(aiTipFutureProvider).asData?.value;
      final topTipster = ref.watch(topTipsterProvider).asData?.value;
      final feedActivity = ref.watch(latestFeedActivityProvider).asData?.value;
      final challenges = ref.watch(activeChallengesProvider).asData?.value;
      if (aiTip != null) {
        tiles.add(HomeTileAiTip(tip: aiTip));
      }
      if (topTipster != null) {
        tiles.add(HomeTileTopTipster(stats: topTipster));
      }
      if (feedActivity != null) {
        tiles.add(
          HomeTileFeedActivity(
            entry: feedActivity,
            onTap: () => context.goNamed(AppRoute.feed.name),
          ),
        );
      }
      if (challenges != null && challenges.isNotEmpty) {
        tiles.add(
          HomeTileChallengePrompt(
            challenge: challenges.first,
            onAccept: () =>
                context.goNamed(AppRoute.createTicket.name),
          ),
        );
      }
      if (ref.watch(dailyBonusAvailableProvider)) {
        tiles.add(const HomeTileDailyBonus());
      }
      final earned = ref.watch(latestBadgeProvider).asData?.value;
      if (earned != null &&
          DateTime.now().difference(earned.timestamp).inDays <= 3) {
        tiles.add(
          HomeTileBadgeEarned(
            badge: earned,
            onTap: () => context.goNamed(AppRoute.badges.name),
          ),
        );
      }
      body = statsAsync.when(
        data: (stats) => Column(
          children: [
            UserStatsHeader(stats: stats),
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
        error: (_, _) => const SizedBox.shrink(),
      );
    } else {
      body = child;
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
        title: Text(loc.home_title),
        actions: const [NotificationBellWidget()],
      ),
      drawer: const AppDrawer(),
      body: body,
      bottomNavigationBar: const MyBottomNavigationBar(),
    );
  }
}

