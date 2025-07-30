import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:firebase_app_check/firebase_app_check.dart';

class RecaptchaService {
  final http.Client _client;
  final String secret;

  RecaptchaService({required this.secret, http.Client? client})
    : _client = client ?? http.Client();

  /// Returns a token from the platform's reCAPTCHA implementation.
  /// In debug mode a dummy value is returned.
  Future<String> execute() async {
    // Debug / teszt környezetben shortcut token
    if (kDebugMode) return 'debug-token';

    // Web – Firebase Auth invisible reCAPTCHA
    if (kIsWeb) {
      // Web implementation is handled via Firebase Auth directly.
      return '';
    }

    // Mobile – App Check token
    final token = await FirebaseAppCheck.instance.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Unable to acquire reCAPTCHA token');
    }
    return token;
  }

  Future<bool> verifyToken(String token) async {
    // Debug környezetben nem hívjuk a Google API-t, mindig true-t adunk vissza,
    // hogy a fejlesztői tesztek ne akadjanak meg.
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
