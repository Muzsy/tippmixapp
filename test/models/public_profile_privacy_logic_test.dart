import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/models/user_model.dart';

void main() {
  group('Public profile privacy', () {
    test('visible fields honor fieldVisibility', () {
      final user = UserModel(
        uid: 'u1',
        email: 'a@b.com',
        displayName: 'Disp',
        nickname: 'Nick',
        avatarUrl: 'https://example.com/a.png',
        isPrivate: false,
        fieldVisibility: const {'city': true, 'country': false},
      );
      expect(user.fieldVisibility['city'], isTrue);
    });

    test('global private hides all', () {
      final user = UserModel(
        uid: 'u1',
        email: 'a@b.com',
        displayName: 'Disp',
        nickname: 'Nick',
        avatarUrl: 'https://example.com/a.png',
        isPrivate: true,
        fieldVisibility: const {'city': true},
      );
      expect(user.isPrivate, isTrue);
    });
  });
}
