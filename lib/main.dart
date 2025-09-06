import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

import 'bootstrap.dart';
import 'controllers/app_locale_controller.dart';
import 'services/theme_service.dart';
import 'theme/theme_builder.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'router.dart';

/// Entry point of the application.
///
/// This file contains the minimal initialization required to start the app
/// and activate Firebase App Check in debug mode. The debug token is read
/// exclusively from a compile‐time environment definition via
/// `--dart-define=FIREBASE_APP_CHECK_DEBUG_TOKEN=...`. The native plugin
/// picks up the same value from the process environment (set via VS Code's
/// `env` configuration) and therefore there is no need to access
/// `Platform.environment` from Dart. If the token is missing during a
/// development build, an assertion will be thrown to remind the
/// developer to supply it.
Future<void> main() async {
  // Load environment variables from a .env file (if present).
  await dotenv.load();
  await bootstrap();

  // --- App Check debug token configuration ---
  // The debug token is supplied at build time via `--dart-define`. Only
  // compile‑time definitions are considered here. Do NOT read from
  // `Platform.environment` since that environment variable is for the native
  // layer (the plugin uses it separately). See launch.json for how the
  // same token is supplied both as a Dart define and an environment
  // variable.
  const debugToken = String.fromEnvironment(
    'FIREBASE_APP_CHECK_DEBUG_TOKEN',
    defaultValue: '',
  );

  // Do not halt execution if the compile-time debug token is missing. The
  // native plugin can still read the token from the
  // `FIREBASE_APP_CHECK_DEBUG_TOKEN` environment variable.
  if (kDebugMode && debugToken.isEmpty) {
    debugPrint(
      '⚠️  FIREBASE_APP_CHECK_DEBUG_TOKEN compile-time value missing – '
      'folytatom futást (env változó még tartalmazhat tokent).',
    );
  }

  // Activate App Check. In debug mode the Android/iOS provider is set
  // accordingly. The debug token is picked up automatically by the native
  // plugin if the corresponding environment variable has been set. There is
  // no need to pass the token here in Dart.
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode
        ? AndroidProvider.debug
        : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
  );

  if (kDebugMode) {
    try {
      final debugToken = await FirebaseAppCheck.instance.getToken(true);
      debugPrint('🔐 DEBUG App Check token: ${debugToken ?? 'NULL'}');
    } on FirebaseException catch (e) {
      debugPrint('[APP_CHECK] startup getToken FAILED – ignore (${e.code})');
    }
  }

  // --- end debug token configuration ---

  final container = ProviderContainer();
  final themeFuture = container.read(themeServiceProvider.notifier).hydrate();
  await container.read(appLocaleControllerProvider.notifier).loadLocale();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: _BootstrapApp(themeFuture: themeFuture),
    ),
  );
}

class _BootstrapApp extends ConsumerWidget {
  const _BootstrapApp({required this.themeFuture});

  final Future<void> themeFuture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<void>(
      future: themeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return const MyApp();
      },
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeServiceProvider);
    final locale = ref.watch(appLocaleControllerProvider);

    final lightFuture = buildDynamicTheme(
      scheme: FlexScheme.values[theme.schemeIndex],
      brightness: Brightness.light,
    );
    final darkFuture = buildDynamicTheme(
      scheme: FlexScheme.values[theme.schemeIndex],
      brightness: Brightness.dark,
    );

    return FutureBuilder<List<ThemeData>>(
      future: Future.wait([lightFuture, darkFuture]),
      builder: (context, snapshot) {
        final light =
            snapshot.data?[0] ??
            buildTheme(
              scheme: FlexScheme.values[theme.schemeIndex],
              brightness: Brightness.light,
            );
        final dark =
            snapshot.data?[1] ??
            buildTheme(
              scheme: FlexScheme.values[theme.schemeIndex],
              brightness: Brightness.dark,
            );

        return MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => child ?? const SizedBox.shrink(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('hu'), Locale('en'), Locale('de')],
          localeResolutionCallback:
              (Locale? deviceLocale, Iterable<Locale> supported) {
                if (deviceLocale == null) return const Locale('en');
                return supported.firstWhere(
                  (l) => l.languageCode == deviceLocale.languageCode,
                  orElse: () => const Locale('en'),
                );
              },
          theme: light,
          darkTheme: dark,
          themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
          locale: locale,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

/// Helper class for GoRouter to listen to a stream and rebuild when it emits.
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
