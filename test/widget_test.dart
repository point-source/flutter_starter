/// Smoke tests verifying core types and infrastructure compile and behave.
///
/// These quick checks ensure the foundational types ([FailureException],
/// [AppEnvironment]) work correctly without requiring a full Flutter
/// widget test pump.
library;

import 'package:flutter_starter/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FailureException', () {
    /// Wraps a [Failure] and exposes it via the [failure] getter.
    test('wraps a Failure value', () {
      const failure = UnexpectedFailure('oops');
      const exception = FailureException(failure);

      expect(exception.failure, same(failure));
      expect(exception.failure.message, 'An unexpected error occurred');
    });

    /// Produces a human-readable string including the failure message.
    test('toString includes failure message', () {
      const failure = UnexpectedFailure('oops');
      const exception = FailureException(failure);

      expect(exception.toString(), contains('FailureException'));
      expect(exception.toString(), contains('An unexpected error occurred'));
    });

    /// Implements [Exception] so it integrates with Dart's error handling.
    test('implements Exception', () {
      const exception = FailureException(UnexpectedFailure('x'));
      expect(exception, isA<Exception>());
    });
  });
}
