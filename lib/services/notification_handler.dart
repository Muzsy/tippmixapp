import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_model.dart';
import '../routes/app_route.dart';

class NotificationHandler {
  NotificationHandler({GoRouter? router}) : _router = router;

  final GoRouter? _router;

  AppRoute? _routeFor(String? destination) {
    if (destination == null) return null;
    for (final r in AppRoute.values) {
      if (r.name == destination) return r;
    }
    return null;
  }

  void handle(BuildContext context, NotificationModel model) {
    final route = _routeFor(model.destination);
    if (route != null) {
      final r = _router ?? GoRouter.of(context);
      r.goNamed(route.name);
    }
  }
}

final notificationHandlerProvider = Provider((ref) => NotificationHandler());
