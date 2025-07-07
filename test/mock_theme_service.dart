import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:tippmixapp/services/theme_service.dart';

/// Simple mock implementation of [ThemeService] for widget tests.
///
/// Returns a fixed light theme for all calls so golden tests can
/// run without depending on shared preferences or Firebase.
class MockThemeService extends ThemeService {
  MockThemeService() : super();

  static const FlexScheme _defaultScheme = FlexScheme.dellGenoa;

  /// List containing a single mock theme.
  List<FlexScheme> get availableThemes => [_defaultScheme];

  /// Returns the active mock theme.
  FlexScheme getActiveTheme() => _defaultScheme;

  @override
  Future<void> hydrate() async {
    // Ensure default state without touching storage.
    state = const ThemeState();
  }

  @override
  Future<void> saveTheme() async {}

  @override
  Future<void> saveDarkMode() async {}
}
