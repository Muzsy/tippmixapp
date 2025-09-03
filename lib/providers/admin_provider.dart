import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides whether the current user has admin privileges.
///
/// In production this should reflect a custom claim from Firebase Auth.
/// For now it defaults to `false` and can be overridden in tests.
final isAdminProvider = Provider<bool>((ref) => false);
