import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/screens/home_screen.dart';
// import 'package:tippmixapp/screens/home_body_screen.dart';
import 'package:tippmixapp/screens/profile_screen.dart';
import 'package:tippmixapp/screens/my_tickets_screen.dart';
import 'package:tippmixapp/screens/events_screen.dart';
import 'package:tippmixapp/screens/login_register_screen.dart';
import 'package:tippmixapp/screens/leaderboard/leaderboard_screen.dart';
import 'package:tippmixapp/screens/settings/settings_screen.dart';
import 'package:tippmixapp/screens/badges/badge_screen.dart';
import 'package:tippmixapp/screens/rewards/rewards_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tippmixapp/screens/create_ticket_screen.dart';
// import 'package:tippmixapp/screens/feed_screen.dart';
import 'routes/app_route.dart';
import 'package:tippmixapp/screens/notifications/notification_center_screen.dart';

// import 'package:tippmixapp/providers/auth_provider.dart'; // Későbbi bővítéshez

final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final protectedPaths = [
      '/my-tickets',
      '/create-ticket',
      '/settings',
      '/notifications',
    ];
    final accessingProtected = protectedPaths.contains(state.uri.path);
    if (user == null && accessingProtected) return '/login';
    return null;
  },
  routes: [
    ShellRoute(
      builder: (context, state, child) => HomeScreen(child: child, state: state),
      routes: [
        GoRoute(
          path: '/create-ticket',
          name: AppRoute.createTicket.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const CreateTicketScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/',
          name: AppRoute.home.name,
          builder: (context, state) => const EventsScreen(sportKey: 'soccer'),
        ),
        GoRoute(
          path: '/profile',
          name: AppRoute.profile.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const ProfileScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/events',
          name: AppRoute.events.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const EventsScreen(sportKey: 'soccer'),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/my-tickets',
          name: AppRoute.myTickets.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const MyTicketsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          name: AppRoute.feed.name,
          path: '/feed',
          builder: (context, state) => const EventsScreen(sportKey: 'soccer'),
        ),
        GoRoute(
          path: '/leaderboard',
          name: AppRoute.leaderboard.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const LeaderboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/badges',
          name: AppRoute.badges.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const BadgeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/rewards',
          name: AppRoute.rewards.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const RewardsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/notifications',
          name: AppRoute.notifications.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const NotificationCenterScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/settings',
          name: AppRoute.settings.name,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const SettingsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/login',
          name: AppRoute.login.name,
          pageBuilder: (context, state) => CustomTransitionPage(
          child: const LoginRegisterScreen(),
          transitionsBuilder: (context, anim, secAnim, child) =>
              FadeTransition(opacity: anim, child: child),
          ),
        )
     ],
    ),
    // Opcionális: login vagy egyéb top-level oldalak
    // GoRoute(
    //   path: '/login',
    //   name: 'login',
    //   pageBuilder: ...,
    // ),
  ],
);
