import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/screens/home_screen.dart';
import 'package:tippmixapp/screens/feed_screen.dart';
import 'package:tippmixapp/routes/app_route.dart';

void main() {
  testWidgets('AppBar shows feed title on /feed route', (tester) async {
    final router = GoRouter(
      initialLocation: '/feed',
      routes: [
        ShellRoute(
          builder: (context, state, child) => HomeScreen(state: state, child: child),
          routes: [
            GoRoute(
              path: '/',
              name: AppRoute.home.name,
              builder: (context, state) => const SizedBox.shrink(),
            ),
            GoRoute(
              path: '/feed',
              name: AppRoute.feed.name,
              builder: (context, state) => const FeedScreen(),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Feed'), findsOneWidget);
  });

  testWidgets('AppBar shows default title on / route', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => HomeScreen(state: state, child: child),
          routes: [
            GoRoute(
              path: '/',
              name: AppRoute.home.name,
              builder: (context, state) => const SizedBox.shrink(),
            ),
            GoRoute(
              path: '/feed',
              name: AppRoute.feed.name,
              builder: (context, state) => const FeedScreen(),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('TippmixApp'), findsOneWidget);
  });
}
