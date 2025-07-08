import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/models/user_model.dart';

void main() {
  group('UserModel.fromJson', () {
    test('throws when required field missing', () {
      expect(() => UserModel.fromJson({}), throwsA(isA<TypeError>()));
    });

    test('parses when all required fields present', () {
      final user = UserModel.fromJson({
        'uid': 'u1',
        'email': 'e',
        'displayName': 'd',
        'nickname': 'n',
        'avatarUrl': 'a',
      });
      expect(user.uid, 'u1');
    });
  });
}
