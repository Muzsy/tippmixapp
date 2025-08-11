import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/providers/bet_slip_provider.dart';
import 'package:tippmixapp/models/tip_model.dart';

TipModel tip(String eventId, String outcome) => TipModel(
  eventId: eventId,
  eventName: 'A – B',
  startTime: DateTime.now().add(const Duration(hours: 1)),
  sportKey: 'soccer',
  bookmaker: 'bk',
  marketKey: 'h2h',
  outcome: outcome,
  odds: 1.5,
);

void main() {
  test('addTip adds once and prevents duplicates', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(betSlipProvider.notifier);
    expect(container.read(betSlipProvider).tips, isEmpty);

    final ok1 = notifier.addTip(tip('e1', 'home'));
    expect(ok1, isTrue);
    expect(container.read(betSlipProvider).tips.length, 1);

    final dup = notifier.addTip(tip('e1', 'home'));
    expect(dup, isFalse);
    expect(container.read(betSlipProvider).tips.length, 1);
  });
}
