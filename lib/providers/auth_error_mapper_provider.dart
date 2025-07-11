import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_error_mapper.dart';

final authErrorMapperProvider = Provider((ref) => AuthErrorMapper());
