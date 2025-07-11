import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_repository.dart';

/// Riverpod provider for [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
