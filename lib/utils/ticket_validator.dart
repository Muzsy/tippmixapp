import 'package:hooks_riverpod/hooks_riverpod.dart';


final ticketValidatorProvider = Provider<TicketValidator>((ref) {
  return TicketValidator();
});

class TicketValidator {
  String? validateStake(double stake) {
    if (stake <= 0) return 'errorInvalidStake';
    return null;
  }

  String? checkDuplicateTips(List<Tip> tips) {
    final ids = <String>{};
    for (final tip in tips) {
      if (!ids.add(tip.id)) return 'errorDuplicate';
    }
    return null;
  }

  String? validateMatchConflicts(List<Tip> tips) {
    final matchIds = <String, int>{};
    for (final tip in tips) {
      matchIds.update(tip.matchId, (v) => v + 1, ifAbsent: () => 1);
      if (matchIds[tip.matchId]! > 1) return 'errorMatchConflict';
    }
    return null;
  }
}
