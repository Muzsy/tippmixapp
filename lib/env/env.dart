import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static String _env(String key) {
    // Priority: --dart-define -> .env via flutter_dotenv -> process env
    String fromDefine = '';
    if (key == 'SUPABASE_URL') {
      fromDefine = const String.fromEnvironment('SUPABASE_URL');
    } else if (key == 'SUPABASE_ANON_KEY') {
      fromDefine = const String.fromEnvironment('SUPABASE_ANON_KEY');
    }
    if (fromDefine.isNotEmpty) return fromDefine;
    final dot = dotenv.maybeGet(key);
    if (dot != null && dot.isNotEmpty) return dot;
    final proc = Platform.environment[key];
    if (proc != null && proc.isNotEmpty) return proc;
    return '';
  }

  static String get supabaseUrl => _env('SUPABASE_URL');
  static String get supabaseAnonKey => _env('SUPABASE_ANON_KEY');

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
