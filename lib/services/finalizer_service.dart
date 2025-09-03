import 'package:cloud_functions/cloud_functions.dart';

/// Service to trigger the match finalizer Cloud Function manually.
class FinalizerService {
  /// Calls the `force_finalizer` HTTPS callable.
  ///
  /// [devOverride] can bypass admin restriction when the backend allows it.
  static Future<String> forceFinalizer({
    bool devOverride = false,
    FirebaseFunctions? functions,
  }) async {
    try {
      final instance =
          functions ?? FirebaseFunctions.instanceFor(region: 'europe-central2');
      final callable = instance.httpsCallable('force_finalizer');
      final res = await callable.call(<String, dynamic>{
        'devOverride': devOverride,
      });
      return (res.data is Map && res.data['status'] == 'OK') ? 'OK' : 'ERROR';
    } catch (e) {
      return 'ERROR: $e';
    }
  }
}
