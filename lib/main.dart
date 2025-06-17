import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async'; // Szükséges a StreamSubscription-hoz

import 'providers/auth_provider.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
import 'screens/login_register_screen.dart';

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
        //final loggingIn = state.uri.toString() == '/login' || state.uri.toString() == '/register';
        final loggingIn = state.uri.path == '/login';
        if (user == null && !loggingIn) return '/login';
        if (user != null && loggingIn) return '/';
        return null;
      },
      routes: [
        // GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        // GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
        GoRoute(path: '/login', builder: (context, _) => const LoginRegisterScreen()),
        //GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        // ...további route-ok
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      // Ide kerülhet még: theme, locale, stb.
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
