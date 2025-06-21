import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/screens/home_screen.dart';
// import 'package:tippmixapp/screens/home_body_screen.dart';
import 'package:tippmixapp/screens/profile_screen.dart';
import 'package:tippmixapp/screens/my_tickets_screen.dart';
import 'package:tippmixapp/screens/events_screen.dart';
import 'package:tippmixapp/screens/login_register_screen.dart';
import 'package:tippmixapp/screens/leaderboard/leaderboard_screen.dart';
// import 'package:tippmixapp/providers/auth_provider.dart'; // Későbbi bővítéshez

final GoRouter router = GoRouter(
  initialLocation: '/',
  // redirect: (context, state) {
  //   // Auth logika később
  //   return null;
  // },
  routes: [
    ShellRoute(
      builder: (context, state, child) => HomeScreen(child: child),
      routes: [
/*      GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const HomeBodyScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ), */
        GoRoute(
          path: '/profile',
          name: 'profile',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const ProfileScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/events',
          name: 'events',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const EventsScreen(sportKey: 'soccer'),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/my-tickets',
          name: 'my_tickets',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const MyTicketsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/leaderboard',
          name: 'leaderboard',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const LeaderboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
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
