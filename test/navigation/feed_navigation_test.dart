import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/screens/events_screen.dart';
import 'package:tippmixapp/screens/feed_screen.dart';
import 'package:tippmixapp/screens/home_screen.dart';
import 'package:tippmixapp/routes/app_route.dart';

void main() {
  testWidgets('navigate to Feed via bottom nav and drawer', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => HomeScreen(child: child),
          routes: [
            GoRoute(
              path: '/',
              name: AppRoute.home.name,
              builder: (context, state) => const EventsScreen(sportKey: 'soccer'),
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
    expect(find.byType(EventsScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dynamic_feed));
    await tester.pumpAndSettle();
    expect(find.byType(FeedScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();
    expect(find.byType(EventsScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Feed'));
    await tester.pumpAndSettle();
    expect(find.byType(FeedScreen), findsOneWidget);
  });
}
