import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/recaptcha_service.dart';

final recaptchaServiceProvider = Provider<RecaptchaService>((ref) {
  // Secret would normally come from secure storage or env
  return RecaptchaService(secret: 'test-secret');
});
