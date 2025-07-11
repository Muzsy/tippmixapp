import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hibp_service.dart';

final hibpServiceProvider = Provider<HIBPService>((ref) {
  return HIBPService();
});
