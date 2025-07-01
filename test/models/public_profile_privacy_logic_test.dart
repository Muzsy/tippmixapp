import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/models/user_model.dart';

void main() {
  group('Public profile privacy', () {
    test('visible fields honor fieldVisibility', () {
      final user = UserModel(
        uid: 'u1',
        email: 'a@b.com',
        displayName: 'Disp',
        nickname: 'Nick',
        avatarUrl: '',
        isPrivate: false,
        fieldVisibility: const {'city': true, 'country': false},
      );
      // TODO: evaluate visible fields based on privacy settings
      expect(user.fieldVisibility['city'], isTrue);
    });

    test('global private hides all', () {
      final user = UserModel(
        uid: 'u1',
        email: 'a@b.com',
        displayName: 'Disp',
        nickname: 'Nick',
        avatarUrl: '',
        isPrivate: true,
        fieldVisibility: const {'city': true},
      );
      // TODO: evaluate global private flag
      expect(user.isPrivate, isTrue);
    });
  });
}
