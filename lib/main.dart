import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'dart:async'; // Szükséges a StreamSubscription-hoz

import 'providers/auth_provider.dart';
import 'controllers/app_theme_controller.dart';
import 'controllers/app_locale_controller.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
import 'screens/login_register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/events_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/my_tickets_screen.dart';
import 'screens/create_ticket_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load();
  runApp(
    ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    final router = GoRouter(
      refreshListenable: GoRouterRefreshStream(
        ref.watch(authProvider.notifier).authStateStream,
      ),
      redirect: (context, state) {
        final subLoc = state.uri.path;
        final loggingIn = subLoc == '/login';
        if (user == null && loggingIn == false) return '/login';
        if (user != null && loggingIn) return '/';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, _) => const LoginRegisterScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => HomeScreen(child: child),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, _) => const EventsScreen(sportKey: 'soccer'),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, _) => const ProfileScreen(),
            ),
            GoRoute(
              path: '/my-tickets',
              builder: (context, _) => const MyTicketsScreen(),
            ),
            GoRoute(
              path: '/create-ticket',
              builder: (context, _) => const CreateTicketScreen(),
            ),
            GoRoute(
              path: '/events',
              builder: (context, _) => const EventsScreen(sportKey: 'soccer'),
            ),
          ],
        ),
      ],
    );

    final themeMode = ref.watch(appThemeControllerProvider);
    final locale = ref.watch(appLocaleControllerProvider);

    return MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      locale: locale,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Segédosztály a stream figyeléséhez, GoRouter számára
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListener = () => notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListener());
  }
  late VoidCallback notifyListener;
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
