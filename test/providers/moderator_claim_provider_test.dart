import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tipsterino/providers/moderator_claim_provider.dart';

class _FakeWatcher implements ClaimsWatcher {
  _FakeWatcher(this._controller);
  final StreamController<Map<String, dynamic>?> _controller;
  @override
  Stream<Map<String, dynamic>?> claims() => _controller.stream;
}

void main() {
  test('emits true when moderator claim present', () async {
    final controller = StreamController<Map<String, dynamic>?>();
    final container = ProviderContainer(overrides: [
      claimsWatcherProvider.overrideWithValue(_FakeWatcher(controller)),
    ]);
    addTearDown(container.dispose);

    expect(container.read(isModeratorProvider), false);
    controller.add({'roles': {'moderator': true}});
    await container.read(moderatorClaimStreamProvider.future);
    expect(container.read(isModeratorProvider), true);
  });
}
