import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tippmixapp/screens/home_screen.dart';
// import 'package:tippmixapp/screens/home_body_screen.dart';
import 'package:tippmixapp/screens/profile_screen.dart';
import 'package:tippmixapp/screens/profile/edit_profile_screen.dart';
import 'package:tippmixapp/screens/my_tickets_screen.dart';
import 'package:tippmixapp/screens/events_screen.dart';
import 'package:tippmixapp/screens/auth/login_screen.dart';
import 'package:tippmixapp/screens/leaderboard/leaderboard_screen.dart';
import 'package:tippmixapp/screens/settings/settings_screen.dart';
import 'package:tippmixapp/screens/badges/badge_screen.dart';
import 'package:tippmixapp/ui/auth/auth_gate.dart';
import 'package:tippmixapp/screens/rewards/rewards_screen.dart';
import 'package:tippmixapp/screens/social/friends_screen.dart';
import 'package:tippmixapp/providers/auth_guard.dart';
import 'package:tippmixapp/screens/create_ticket_screen.dart';
import 'package:tippmixapp/screens/feed_screen.dart';
import 'package:tippmixapp/screens/onboarding/onboarding_flow_screen.dart';
import 'package:tippmixapp/screens/splash_screen.dart';
import 'package:tippmixapp/screens/register_wizard.dart';
import 'routes/app_route.dart';
import 'package:tippmixapp/screens/notifications/notification_center_screen.dart';
import 'package:tippmixapp/screens/debug/debug_menu_screen.dart';
import 'package:tippmixapp/screens/forgot_password_screen.dart';
import 'package:tippmixapp/screens/password_reset_confirm_screen.dart';
import 'package:tippmixapp/screens/reset_password_screen.dart';
import 'package:tippmixapp/screens/auth/email_not_verified_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// import 'package:tippmixapp/providers/auth_provider.dart'; // Későbbi bővítéshez

String? _redirect(BuildContext context, GoRouterState state) {
  User? user;
  if (Firebase.apps.isNotEmpty) {
    user = FirebaseAuth.instance.currentUser;
  }
  final loggedIn = user != null; // meglévő logika
  final loc = state.matchedLocation;
  const publicPaths = {'/', '/login', '/register', '/onboarding', '/splash'};
  if (!loggedIn && !publicPaths.contains(loc)) {
    return '/login';
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
