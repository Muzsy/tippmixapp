import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class RecaptchaService {
  final http.Client _client;
  final String secret;

  RecaptchaService({required this.secret, http.Client? client})
    : _client = client ?? http.Client();

  Future<bool> verifyToken(String token) async {
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
