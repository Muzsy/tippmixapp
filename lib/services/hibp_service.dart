import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart'; // ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:clock/clock.dart';

class _CacheEntry {
  final bool value;
  final DateTime expiry;
  _CacheEntry(this.value, this.expiry);
}

class HIBPService {
  final http.Client _client;
  final Clock _clock;
  final Map<String, _CacheEntry> _cache = {};

  HIBPService({http.Client? client, Clock? clockOverride})
    : _client = client ?? http.Client(),
      _clock = clockOverride ?? const Clock();

  Future<bool> isPasswordPwned(String password) async {
    final hash = sha1.convert(utf8.encode(password)).toString().toUpperCase();
    final cached = _cache[hash];
    final now = _clock.now();
    if (cached != null && now.isBefore(cached.expiry)) {
      return cached.value;
    }
    final prefix = hash.substring(0, 5);
    final suffix = hash.substring(5);
    final uri = Uri.parse('https://api.pwnedpasswords.com/range/$prefix');
    final response = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw http.ClientException('hibp_error');
    }
    final lines = const LineSplitter().convert(response.body);
    final pwned = lines.any((line) {
      final parts = line.split(':');
      return parts.first.toUpperCase() == suffix;
    });
    _cache[hash] = _CacheEntry(pwned, now.add(const Duration(hours: 24)));
    return pwned;
  }
}
