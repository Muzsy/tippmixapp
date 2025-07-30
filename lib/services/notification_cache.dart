import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_model.dart';

class NotificationCache {
  NotificationCache(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'notification_cache_v2';

  Future<void> save(List<NotificationModel> notifications) async {
    var list = notifications;
    if (list.length > 50) {
      list = list.sublist(list.length - 50);
    }
    final jsonList = list
        .map((n) => jsonEncode({'id': n.id, ...n.toJson()}))
        .toList();
    await _prefs.setStringList(_key, jsonList);
  }

  List<NotificationModel> load() {
    final jsonList = _prefs.getStringList(_key) ?? <String>[];
    return [
      for (final str in jsonList)
        (() {
          final map = jsonDecode(str) as Map<String, dynamic>;
          final id = map.remove('id') as String? ?? '';
          return NotificationModel.fromJson(id, map);
        })(),
    ];
  }
}
