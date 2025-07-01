import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/odds_event.dart';
import '../models/odds_api_response.dart';
import '../services/odds_api_service.dart';
import '../services/odds_cache_wrapper.dart';

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
  final OddsCacheWrapper _wrapper;
  OddsApiProvider(this._wrapper) : super(OddsApiLoading());

  /// Események lekérése sport (és később liga/idő) szerint.
  Future<void> fetchOdds({required String sport}) async {
    // Fetch odds for the selected sport
    state = OddsApiLoading();
    final response = await _wrapper.getOdds(sport: sport);

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
  (ref) => OddsApiProvider(OddsCacheWrapper(OddsApiService())),
);
