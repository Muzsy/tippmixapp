import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In Supabase mode, moderator status is resolved via app logic/server roles.
/// Provide a simple false default; wire to real role checks if needed.
final isModeratorProvider = Provider<bool>((ref) => false);
