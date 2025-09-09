import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Abstraction for watching custom claims from Firebase Auth tokens.
abstract class ClaimsWatcher {
  Stream<Map<String, dynamic>?> claims();
}

class FirebaseClaimsWatcher implements ClaimsWatcher {
  FirebaseClaimsWatcher(this._auth);
  final fb.FirebaseAuth _auth;

  @override
  Stream<Map<String, dynamic>?> claims() async* {
    await for (final user in _auth.idTokenChanges()) {
      if (user == null) {
        yield null;
      } else {
        final token = await user.getIdTokenResult(true);
        yield token.claims;
      }
    }
  }
}

final firebaseAuthProvider =
    Provider<fb.FirebaseAuth>((ref) => fb.FirebaseAuth.instance);

final claimsWatcherProvider = Provider<ClaimsWatcher>((ref) {
  return FirebaseClaimsWatcher(ref.watch(firebaseAuthProvider));
});

final moderatorClaimStreamProvider =
    StreamProvider<bool>((ref) => ref.watch(claimsWatcherProvider)
        .claims()
        .map((claims) {
      final roles = claims?['roles'] as Map<String, dynamic>?;
      return roles?['moderator'] == true;
    }));

/// Synchronous boolean access to moderator status.
final isModeratorProvider = Provider<bool>((ref) => ref
    .watch(moderatorClaimStreamProvider)
    .maybeWhen(data: (v) => v, orElse: () => false));
