import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/models/profile.dart';

void main() {
  test('fromJson/toJson roundtrip', () {
    final profile = Profile(
      uid: '123',
      displayName: 'Foo',
      avatarUrl: 'http://example.com',
      createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
      coins: 1000,
    );
    final json = profile.toJson();
    final other = Profile.fromJson(json);
    expect(other.uid, profile.uid);
    expect(other.displayName, profile.displayName);
    expect(other.avatarUrl, profile.avatarUrl);
    expect(
      other.createdAt.toIso8601String(),
      profile.createdAt.toIso8601String(),
    );
    expect(other.coins, profile.coins);
  });
}
