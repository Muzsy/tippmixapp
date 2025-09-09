import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tipsterino/widgets/my_bottom_navigation_bar.dart';
import 'package:tipsterino/routes/app_route.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

void main() {
  testWidgets('forum tab navigates to /forum', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          name: AppRoute.home.name,
          builder: (_, __) => const Scaffold(
            bottomNavigationBar: MyBottomNavigationBar(),
          ),
        ),
        GoRoute(
          path: '/forum',
          name: AppRoute.forum.name,
          builder: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));
    await tester.tap(find.byIcon(Icons.forum));
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.fullPath, '/forum');
  });
}
