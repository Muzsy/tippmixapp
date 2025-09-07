import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";

/// Service responsible for fetching and caching remote experiment variants.
class ExperimentService {
  ExperimentService({
    FirebaseRemoteConfig? remoteConfig,
    SharedPreferences? prefs,
  })  : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance,
        _prefs = prefs,
        _customRemoteConfig = remoteConfig != null;

  final FirebaseRemoteConfig _remoteConfig;
  SharedPreferences? _prefs;
  final bool _customRemoteConfig;

  static const _variantKey = 'login_variant';
  static const _timestampKey = 'login_variant_ts';
  static const _overrideKey = 'login_variant_override';

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Returns the login variant ('A' or 'B'). Defaults to 'A' when unavailable.
  Future<String> getLoginVariant() async {
    await _initPrefs();
    final override = _prefs!.getString(_overrideKey);
    if (override != null) return override;

    final ts = _prefs!.getInt(_timestampKey);
    final cached = _prefs!.getString(_variantKey);
    if (ts != null && cached != null) {
      final age = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(ts),
      );
      if (age.inDays < 28) return cached;
    }

    // Offline/dev mode: skip network fetch and return deterministic default
    // If a custom remote config is provided (e.g., in tests), always allow
    // network flow so fakes/mocks can be exercised.
    const bool useEmu = bool.fromEnvironment('USE_EMULATOR', defaultValue: true);
    final bool skipNetwork = useEmu && !_customRemoteConfig;
    if (skipNetwork) {
      final variant = cached ?? 'A';
      await _saveVariant(variant);
      return variant;
    }

    try {
      await _remoteConfig.fetchAndActivate();
      final fetched = _remoteConfig.getString(_variantKey);
      final variant = fetched.isNotEmpty ? fetched : 'A';
      await _saveVariant(variant);
      return variant;
    } catch (_) {
      return cached ?? 'A';
    }
  }

  Future<void> _saveVariant(String variant) async {
    await _prefs!.setString(_variantKey, variant);
    await _prefs!.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Overrides the variant for testing via the debug menu.
  Future<void> overrideVariant(String? variant) async {
    await _initPrefs();
    if (variant == null) {
      await _prefs!.remove(_overrideKey);
    } else {
      await _prefs!.setString(_overrideKey, variant);
    }
  }
}

/// Riverpod provider for [ExperimentService].
final experimentServiceProvider = Provider((ref) => ExperimentService());
