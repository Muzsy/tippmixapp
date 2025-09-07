import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tipsterino/models/notification_model.dart';
import 'package:tipsterino/routes/app_route.dart';
import 'package:tipsterino/services/notification_handler.dart';

class FakeRouter extends Fake implements GoRouter {
  String? navigated;
  @override
  void goNamed(
    String name, {
    Object? extra,
    String? fragment,
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
  }) {
    navigated = name;
  }
}

void main() {
  test('maps destination to route', () {
    final router = FakeRouter();
    final handler = NotificationHandler(router: router);
    final context = FakeBuildContext();
    final model = NotificationModel(
      id: 'n1',
      type: NotificationType.reward,
      title: 't',
      description: 'd',
      timestamp: DateTime.now(),
      category: NotificationCategory.rewards,
      destination: AppRoute.rewards.name,
    );
    handler.handle(context, model);
    expect(router.navigated, AppRoute.rewards.name);
  });
}

class FakeBuildContext extends Fake implements BuildContext {}
