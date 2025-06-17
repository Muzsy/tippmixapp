import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tip_model.dart';

/// BetSlipProviderState – csak a szelvény aktuális tipjei.
class BetSlipProviderState {
  final List<TipModel> tips;

  BetSlipProviderState({required this.tips});

  BetSlipProviderState copyWith({List<TipModel>? tips}) =>
      BetSlipProviderState(tips: tips ?? this.tips);
}

/// BetSlipProvider logika.
/// - Tipp hozzáadása csak ha nem duplikált és nincs túl a maximumon.
/// - Tipp törlése, teljes szelvény törlése.
class BetSlipProvider extends StateNotifier<BetSlipProviderState> {
  static const int maxTips = 12; // projektelv szerinti maximum

  BetSlipProvider() : super(BetSlipProviderState(tips: []));

  /// Tipp hozzáadása.
  /// true: sikerült, false: duplikált vagy túl sok tipp.
  bool addTip(TipModel tip) {
    // Duplikáció: eseményId+piac+kimenetel alapján (csak egy ilyen lehet)
    final isDuplicate = state.tips.any((t) =>
      t.eventId == tip.eventId &&
      t.marketKey == tip.marketKey &&
      t.outcome == tip.outcome
    );
    if (isDuplicate || state.tips.length >= maxTips) {
      return false;
    }
    state = state.copyWith(tips: [...state.tips, tip]);
    return true;
  }

  /// Tipp törlése esemény+piac+kimenetel alapján.
  void removeTip(TipModel tip) {
    state = state.copyWith(
      tips: state.tips.where((t) =>
        !(t.eventId == tip.eventId &&
          t.marketKey == tip.marketKey &&
          t.outcome == tip.outcome)
      ).toList(),
    );
  }

  /// Teljes szelvény törlése.
  void clearSlip() {
    state = state.copyWith(tips: []);
  }
}

/// Globális Riverpod provider.
final betSlipProvider =
    StateNotifierProvider<BetSlipProvider, BetSlipProviderState>(
        (ref) => BetSlipProvider());
