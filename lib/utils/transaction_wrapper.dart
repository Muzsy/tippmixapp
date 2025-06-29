import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'simple_logger.dart';

class TooManyAttemptsException implements Exception {}

/// Wraps [FirebaseFirestore.runTransaction] with retry logic.
class TransactionWrapper {
  TransactionWrapper({
    required FirebaseFirestore firestore,
    required Logger logger,
    this.maxRetries = 3,
    this.delayBetweenRetries = Duration.zero,
  })  : _firestore = firestore,
        _logger = logger;

  final FirebaseFirestore _firestore;
  final Logger _logger;
  final int maxRetries;
  final Duration delayBetweenRetries;
  Future<void> _queue = Future.value();

  /// Runs the given transaction [body] with retry logic.
  Future<T> run<T>(Future<T> Function(Transaction) body) {
    final operation = _queue.then((_) => _runWithRetry(body));
    _queue =
        operation.whenComplete(() {}).catchError<void>((Object _) {});
    return operation;
  }

  Future<T> _runWithRetry<T>(Future<T> Function(Transaction) body) async {
    var attempt = 0;
    while (true) {
      attempt++;
      try {
        _logger.info('[TransactionWrapper] attempt $attempt');
        return await _firestore.runTransaction(body);
      } on FirebaseException catch (e) {
        final retriable =
            e.code == 'aborted' || e.code == 'deadline-exceeded';
        if (!retriable) rethrow;
        if (attempt >= maxRetries) {
          throw TooManyAttemptsException();
        }
      }
      if (delayBetweenRetries > Duration.zero) {
        await Future<void>.delayed(delayBetweenRetries);
      }
    }
  }
}
