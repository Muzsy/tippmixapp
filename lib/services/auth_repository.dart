import 'package:cloud_functions/cloud_functions.dart';

/// Thrown when the checked email already exists in backend.
class EmailAlreadyInUseFailure implements Exception {}

/// Repository handling auth related network calls.
class AuthRepository {
  final FirebaseFunctions _functions;

  AuthRepository({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  /// Returns `true` if the email does not exist yet.
  ///
  /// Throws [EmailAlreadyInUseFailure] when the backend
  /// responds with HTTP 409 or `already-exists` code.
  Future<bool> isEmailAvailable(String email) async {
    final callable = _functions.httpsCallable('checkEmail');
    try {
      await callable.call({'email': email});
      return true;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'already-exists' || e.details == 409) {
        throw EmailAlreadyInUseFailure();
      }
      rethrow;
    }
  }
}
