import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tip_model.dart';


final ticketValidatorProvider = Provider<TicketValidator>((ref) {
  return TicketValidator();
});

class TicketValidator {
  String? validateStake(double stake) {
    if (stake <= 0) return 'errorInvalidStake';
    return null;
  }

  String? checkDuplicateTips(List<TipModel> tips) {
    final ids = <String>{};
    for (final tip in tips) {
      final tipId = '${tip.eventId}_${tip.marketKey}_${tip.outcome}';
      if (!ids.add(tipId)) return 'errorDuplicate';
    }
    return null;
  }

  String? validateMatchConflicts(List<TipModel> tips) {
    final matchIds = <String, int>{};
    for (final tip in tips) {
      matchIds.update(tip.eventId, (v) => v + 1, ifAbsent: () => 1);
      if (matchIds[tip.eventId]! > 1) return 'errorMatchConflict';
    }
    return null;
  }
}
