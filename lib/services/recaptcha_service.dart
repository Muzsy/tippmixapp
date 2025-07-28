import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class RecaptchaService {
  final http.Client _client;
  final String secret;

  RecaptchaService({required this.secret, http.Client? client})
    : _client = client ?? http.Client();

  /// Returns a token from the platform's reCAPTCHA implementation.
  /// In debug mode a dummy value is returned.
  Future<String> execute() async {
    if (kDebugMode) return 'debug-token';
    // TODO: integrate real reCAPTCHA execution
    return '';
  }

  Future<bool> verifyToken(String token) async {
    // In debug environment skip the network call so developer tests run fast.
    if (kDebugMode) return true;

    final response = await _client
        .post(
          Uri.parse('https://www.google.com/recaptcha/api/siteverify'),
          body: {'secret': secret, 'response': token},
        )
        .timeout(const Duration(seconds: 4));
    if (response.statusCode != 200) return false;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final score = (data['score'] as num?) ?? 0;
    return data['success'] == true && score >= 0.5;
  }
}
