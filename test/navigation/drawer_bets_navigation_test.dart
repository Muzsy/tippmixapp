import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/screens/home_screen.dart';
import 'package:tippmixapp/screens/events_screen.dart';
import 'package:tippmixapp/routes/app_route.dart';

void main() {
  testWidgets('drawer bets item closes drawer and navigates with title', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => HomeScreen(child: child, state: state),
          routes: [
            GoRoute(
              path: '/',
              name: AppRoute.home.name,
              builder: (context, state) => const SizedBox.shrink(),
            ),
            GoRoute(
              path: '/bets',
              name: AppRoute.bets.name,
              pageBuilder: (context, state) => CustomTransitionPage(
                child: const EventsScreen(sportKey: 'soccer'),
                transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
              ),
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

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Bets'));
    await tester.pumpAndSettle();

    expect(find.byType(EventsScreen), findsOneWidget);
    expect(find.text('Bets'), findsOneWidget);
    final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold).first);
    expect(scaffoldState.isDrawerOpen, isFalse);
  });
}
