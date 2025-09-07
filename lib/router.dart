import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tipsterino/screens/home_screen.dart';
// import 'package:tipsterino/screens/home_body_screen.dart';
import 'package:tipsterino/screens/profile_screen.dart';
import 'package:tipsterino/screens/profile/edit_profile_screen.dart';
import 'package:tipsterino/screens/my_tickets_screen.dart';
import 'package:tipsterino/screens/events_screen.dart';
import 'package:tipsterino/screens/auth/login_screen.dart';
import 'package:tipsterino/screens/leaderboard/leaderboard_screen.dart';
import 'package:tipsterino/screens/settings/settings_screen.dart';
import 'package:tipsterino/screens/badges/badge_screen.dart';
import 'package:tipsterino/ui/auth/auth_gate.dart';
import 'package:tipsterino/screens/rewards/rewards_screen.dart';
import 'package:tipsterino/screens/social/friends_screen.dart';
import 'package:tipsterino/providers/auth_guard.dart';
import 'package:tipsterino/screens/create_ticket_screen.dart';
import 'package:tipsterino/screens/feed_screen.dart';
import 'package:tipsterino/screens/onboarding/onboarding_flow_screen.dart';
import 'package:tipsterino/screens/splash_screen.dart';
import 'package:tipsterino/screens/register_wizard.dart';
import 'routes/app_route.dart';
import 'package:tipsterino/screens/notifications/notification_center_screen.dart';
import 'package:tipsterino/screens/debug/debug_menu_screen.dart';
import 'package:tipsterino/screens/forgot_password_screen.dart';
import 'package:tipsterino/screens/password_reset_confirm_screen.dart';
import 'package:tipsterino/screens/reset_password_screen.dart';
import 'package:tipsterino/screens/auth/email_not_verified_screen.dart';
import 'providers/auth_provider.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// import 'package:tipsterino/providers/auth_provider.dart'; // Későbbi bővítéshez

String? _redirect(BuildContext context, GoRouterState state) {
  final container = ProviderScope.containerOf(context, listen: false);
  final authState = container.read(authProvider);
  final isVerified = container.read(authProvider.notifier).isEmailVerified;
  final loggedIn = authState.user != null;
  final loc = state.matchedLocation;
  const publicPaths = {
    '/',
    '/login',
    '/register',
    '/onboarding',
    '/splash',
    '/auth/email-not-verified',
  };
  if (!loggedIn && !publicPaths.contains(loc)) {
    return '/login';
  }
  if (loggedIn && !isVerified && loc != '/auth/email-not-verified') {
    return '/auth/email-not-verified';
  }
  return null;
}

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  redirect: _redirect,
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          HomeScreen(state: state, child: child),
      routes: [
        GoRoute(
          path: '/create-ticket',
          name: AppRoute.createTicket.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const RequireAuth(child: CreateTicketScreen()),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/',
          name: AppRoute.home.name,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AuthGate()),
        ),
        GoRoute(
          path: '/profile',
          name: AppRoute.profile.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const RequireAuth(child: ProfileScreen(showAppBar: false)),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/edit-profile',
          name: AppRoute.editProfile.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: EditProfileScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/bets',
          name: AppRoute.bets.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const EventsScreen(sportKey: 'soccer', showAppBar: false),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/my-tickets',
          name: AppRoute.myTickets.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const RequireAuth(child: MyTicketsScreen(showAppBar: false)),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          name: AppRoute.feed.name,
          path: '/feed',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const FeedScreen(showAppBar: false),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/leaderboard',
          name: AppRoute.leaderboard.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const LeaderboardScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/friends',
          name: AppRoute.friends.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const FriendsScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/badges',
          name: AppRoute.badges.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const BadgeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/rewards',
          name: AppRoute.rewards.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const RewardsScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/notifications',
          name: AppRoute.notifications.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const NotificationCenterScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/settings',
          name: AppRoute.settings.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const RequireAuth(child: SettingsScreen()),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/login',
          name: AppRoute.login.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const LoginScreen(),
            transitionsBuilder: (context, anim, secAnim, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        ),
        GoRoute(
          path: '/register',
          name: AppRoute.register.name,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: RegisterWizard()),
        ),
        GoRoute(
          path: '/forgot-password',
          name: AppRoute.forgotPassword.name,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/reset-confirm',
          name: AppRoute.passwordResetConfirm.name,
          builder: (context, state) => const PasswordResetConfirmScreen(),
        ),
        GoRoute(
          path: '/auth/email-not-verified',
          name: AppRoute.emailNotVerified.name,
          builder: (context, state) => const EmailNotVerifiedScreen(),
        ),
      ],
    ),
    // Opcionális: login vagy egyéb top-level oldalak
    GoRoute(
      path: "/debug",
      name: AppRoute.debugMenu.name,
      builder: (context, state) => const DebugMenuScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: AppRoute.onboarding.name,
      builder: (context, state) => const OnboardingFlowScreen(),
    ),
    GoRoute(
      path: '/reset-password/:oobCode',
      name: AppRoute.resetPassword.name,
      builder: (context, state) =>
          ResetPasswordScreen(oobCode: state.pathParameters['oobCode']!),
    ),
    // GoRoute(
    //   path: '/login',
    //   name: 'login',
    //   pageBuilder: ...,
    // ),
  ],
);
