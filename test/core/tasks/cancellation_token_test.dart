/// Verify [CancellationToken] cancellation lifecycle and [CancelledException].
library;

import 'package:flutter_starter/core/tasks/cancellation_token.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CancellationToken', () {
    test('isCancelled starts false', () {
      final token = CancellationToken();
      expect(token.isCancelled, isFalse);
    });

    test('cancel sets isCancelled to true', () {
      final token = CancellationToken()..cancel();
      expect(token.isCancelled, isTrue);
    });

    test('throwIfCancelled is no-op before cancellation', () {
      final token = CancellationToken();
      expect(token.throwIfCancelled, returnsNormally);
    });

    test('throwIfCancelled throws after cancellation', () {
      final token = CancellationToken()..cancel();
      expect(token.throwIfCancelled, throwsA(isA<CancelledException>()));
    });

    test('cancelled future completes after cancel', () async {
      final token = CancellationToken();
      var completed = false;
      unawaited(token.cancelled.then((_) => completed = true));

      // Future should not have completed yet.
      await Future<void>.delayed(.zero);
      expect(completed, isFalse);

      token.cancel();
      await Future<void>.delayed(.zero);
      expect(completed, isTrue);
    });

    test('double cancel is safe', () {
      final token = CancellationToken()..cancel();
      expect(token.cancel, returnsNormally);
      expect(token.isCancelled, isTrue);
    });
  });

  group('CancelledException', () {
    test('toString returns readable message', () {
      const exception = CancelledException();
      expect(exception.toString(), contains('cancelled'));
    });

    test('implements Exception', () {
      const exception = CancelledException();
      expect(exception, isA<Exception>());
    });
  });
}

/// Suppress lints for unawaited futures used intentionally in tests.
// ignore: avoid-unused-parameters
void unawaited(Future<void> future) {}
