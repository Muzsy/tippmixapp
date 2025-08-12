class DriftItem {
  final String fixtureId;
  final String market;
  final String selection;
  final double oldOdds;
  final double newOdds;
  DriftItem({
    required this.fixtureId,
    required this.market,
    required this.selection,
    required this.oldOdds,
    required this.newOdds,
  });
  bool get increased => newOdds > oldOdds;
  double get diff => newOdds - oldOdds;
}

class OddsDriftResult {
  final List<DriftItem> changes;
  OddsDriftResult(this.changes);
  bool hasBlocking(double threshold) =>
      changes.any((c) => (c.diff.abs()) >= threshold);
}
