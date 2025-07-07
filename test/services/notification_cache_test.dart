import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tippmixapp/models/notification_model.dart';
import 'package:tippmixapp/services/notification_cache.dart';

void main() {
  group('NotificationCache', () {
    late SharedPreferences prefs;
    late NotificationCache cache;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      cache = NotificationCache(prefs);
    });

    test('save and load roundtrip', () async {
      final list = [
        NotificationModel(
          id: 'n1',
          type: NotificationType.reward,
          title: 't1',
          description: 'd',
          timestamp: DateTime.now(),
          category: NotificationCategory.rewards,
        ),
      ];
      await cache.save(list);
      final loaded = cache.load();
      expect(loaded.length, 1);
      expect(loaded.first.id, 'n1');
    });

    test('keeps only last 50 items', () async {
      final list = List.generate(
        55,
        (i) => NotificationModel(
          id: '$i',
          type: NotificationType.reward,
          title: 't',
          description: 'd',
          timestamp: DateTime.now(),
          category: NotificationCategory.rewards,
        ),
      );
      await cache.save(list);
      final loaded = cache.load();
      expect(loaded.length, 50);
      expect(loaded.first.id, '5');
    });
  });
}
