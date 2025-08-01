import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/controllers/splash_controller.dart';
import 'package:tippmixapp/routes/app_route.dart';

class MockSplashController extends StateNotifier<AsyncValue<AppRoute>>
    implements SplashController {
  MockSplashController() : super(const AsyncLoading()) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state = const AsyncData(AppRoute.login);
    });
  }
}
