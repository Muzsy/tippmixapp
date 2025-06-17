import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/odds_event.dart';
import '../models/odds_api_response.dart';
import '../services/odds_api_service.dart';

/// OddsApiProviderState – minden lehetséges állapot külön.
abstract class OddsApiProviderState {}

/// Betöltés állapot.
class OddsApiLoading extends OddsApiProviderState {}

/// Sikeres adatbetöltés állapot.
class OddsApiData extends OddsApiProviderState {
  final List<OddsEvent> events;
  final bool quotaWarning;
  OddsApiData(this.events, {this.quotaWarning = false});
}

/// Hiba állapot, mindig ARB kulccsal.
class OddsApiError extends OddsApiProviderState {
  final String errorMessageKey;
  final ApiErrorType errorType;
  OddsApiError(this.errorMessageKey, this.errorType);
}

/// Üres adatlista állapot.
class OddsApiEmpty extends OddsApiProviderState {}

/// OddsApiProvider: minden odds-lista fetch, state-branch, hibakezelés.
class OddsApiProvider extends StateNotifier<OddsApiProviderState> {
  final OddsApiService _service;
  OddsApiProvider(this._service) : super(OddsApiLoading());

  /// Események lekérése sport (és később liga/idő) szerint.
  Future<void> fetchOdds({required String sport}) async {
    state = OddsApiLoading();
    final response = await _service.getOdds(sport: sport);

    // Hibaágak
    if (response.errorType != ApiErrorType.none) {
      if (response.errorType == ApiErrorType.empty) {
        state = OddsApiEmpty();
      } else {
        state = OddsApiError(
            response.errorMessage ?? 'api_error_unknown', response.errorType);
      }
      return;
    }

    // Sikeres adat
    final events = response.data ?? [];
    if (events.isEmpty) {
      state = OddsApiEmpty();
    } else {
      state = OddsApiData(events, quotaWarning: response.rateLimitWarning);
    }
  }
}

/// Globális Riverpod provider.
final oddsApiProvider = StateNotifierProvider<OddsApiProvider, OddsApiProviderState>(
  (ref) => OddsApiProvider(OddsApiService()),
);
