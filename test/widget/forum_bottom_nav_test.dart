import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tipsterino/widgets/my_bottom_navigation_bar.dart';

void main() {
  testWidgets('forum tab navigates to /forum', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            bottomNavigationBar: MyBottomNavigationBar(),
          ),
        ),
        GoRoute(
          path: '/forum',
          builder: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.byIcon(Icons.forum));
    await tester.pumpAndSettle();
    expect(router.location, '/forum');
  });
}
