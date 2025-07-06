import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'dart:async'; // Szükséges a StreamSubscription-hoz

import 'controllers/app_locale_controller.dart';
import 'services/theme_service.dart';
import 'theme/theme_builder.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load();
  final container = ProviderContainer();
  await container.read(appLocaleControllerProvider.notifier).loadLocale();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final theme = ref.watch(themeServiceProvider);
    final locale = ref.watch(appLocaleControllerProvider);

    return MaterialApp.router(
      routerConfig: router,
      builder: (context, child) {
        if (kDebugMode) {
          return AccessibilityTools(child: child ?? const SizedBox.shrink());
        }
        return child ?? const SizedBox.shrink();
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [
        Locale('hu'),
        Locale('en'),
        Locale('de'),
      ],
      localeResolutionCallback: (Locale? deviceLocale, Iterable<Locale> supported) {
        if (deviceLocale == null) return const Locale('en');
        return supported.firstWhere(
          (l) => l.languageCode == deviceLocale.languageCode,
          orElse: () => const Locale('en'),
        );
      },
      theme: buildTheme(
        scheme: FlexScheme.values[theme.schemeIndex],
        brightness: Brightness.light,
      ),
      darkTheme: buildTheme(
        scheme: FlexScheme.values[theme.schemeIndex],
        brightness: Brightness.dark,
      ),
      themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
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
