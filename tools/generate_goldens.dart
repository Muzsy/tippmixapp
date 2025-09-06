import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path/path.dart' as p;

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/theme/available_themes.dart';
import 'package:tipsterino/theme/theme_builder.dart';
import 'package:tipsterino/routes/app_route.dart';
import 'package:tipsterino/screens/home_screen.dart';
import 'package:tipsterino/screens/profile_screen.dart';
import 'package:tipsterino/screens/events_screen.dart';
import 'package:tipsterino/screens/my_tickets_screen.dart';
import 'package:tipsterino/screens/leaderboard/leaderboard_screen.dart';
import 'package:tipsterino/screens/settings/settings_screen.dart';
import 'package:tipsterino/screens/create_ticket_screen.dart';
import 'package:tipsterino/screens/badges/badge_screen.dart';
import 'package:tipsterino/screens/rewards/rewards_screen.dart';
import 'package:tipsterino/screens/feed_screen.dart';
import 'package:tipsterino/screens/notifications/notification_center_screen.dart';
import 'package:tipsterino/screens/auth/login_screen.dart';

/// Generates golden baseline PNGs for each theme, brightness and main route.
///
/// This script does not commit the generated PNGs automatically – run it
/// manually and verify the images before committing.
Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  const size = Size(390, 844); // iPhone 14 dimensions

  final routes = <AppRoute, Widget>{
    AppRoute.home: const HomeScreen(showStats: true, child: SizedBox.shrink()),
    AppRoute.profile: const ProfileScreen(showAppBar: false),
    AppRoute.bets: const EventsScreen(sportKey: 'soccer', showAppBar: false),
    AppRoute.myTickets: const MyTicketsScreen(showAppBar: false),
    AppRoute.leaderboard: const LeaderboardScreen(),
    AppRoute.settings: const SettingsScreen(),
    AppRoute.createTicket: const CreateTicketScreen(),
    AppRoute.badges: const BadgeScreen(),
    AppRoute.rewards: const RewardsScreen(),
    AppRoute.feed: const FeedScreen(showAppBar: false),
    AppRoute.notifications: const NotificationCenterScreen(),
    AppRoute.login: const LoginScreen(),
  };

  for (var i = 0; i < availableThemes.length; i++) {
    final scheme = availableThemes[i];
    for (final brightness in [Brightness.light, Brightness.dark]) {
      final theme = buildTheme(scheme: scheme, brightness: brightness);
      final controller = ScreenshotController();
      for (final entry in routes.entries) {
        final widget = ProviderScope(
          child: MediaQuery(
            data: const MediaQueryData(size: size),
            child: MaterialApp(
              home: entry.value,
              theme: theme,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
            ),
          ),
        );
        final bytes = await controller.captureFromWidget(widget, pixelRatio: 1.0);
        final name =
            '${entry.key.name}_skin${i}_${brightness == Brightness.light ? 'light' : 'dark'}.png';
        final outFile = File(p.join('test', 'goldens', name))
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes);
        stdout.writeln('Generated ${p.normalize(outFile.path)}');
      }
    }
  }
}
