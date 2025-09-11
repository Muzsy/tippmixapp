import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../env/env.dart';
import '../routes/app_route.dart';
import 'package:flutter/widgets.dart';

class SplashController extends StateNotifier<AsyncValue<AppRoute>> {
  SplashController() : super(const AsyncLoading()) {
    _init();
  }

  Future<void> _init() async {
    // Supabase: decide route from auth + user_settings (only if configured)
    if (!Env.isSupabaseConfigured) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state = const AsyncData(AppRoute.login);
      });
      return;
    }
    final u = sb.Supabase.instance.client.auth.currentUser;
    if (u == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state = const AsyncData(AppRoute.login);
      });
      return;
    }
    try {
      final row = await sb.Supabase.instance.client
          .from('user_settings')
          .select('onboarding_completed')
          .eq('user_id', u.id)
          .maybeSingle();
      final data = (row as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
      final done = (data['onboarding_completed'] as bool?) ?? false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state = AsyncData(done ? AppRoute.home : AppRoute.onboarding);
      });
    } catch (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state = const AsyncData(AppRoute.home);
      });
    }
  }
}

final splashControllerProvider =
    StateNotifierProvider<SplashController, AsyncValue<AppRoute>>(
      (ref) => SplashController(),
    );
