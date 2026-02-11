/// Tests for the [Result] sealed class hierarchy.
///
/// Validates the behaviour of [Success] and [Err] across all methods:
/// [when], [map], [flatMap], [getOrElse], [getOrNull], the boolean
/// accessors, and value equality.
library;

import 'package:flutter_test/flutter_test.dart' hide Timeout;

import 'package:flutter_starter/core/error/failures.dart';
import 'package:flutter_starter/core/error/result.dart';

void main() {
  /// Tests for [Success].
  group('Success', () {
    /// when() calls the success branch with the wrapped data.
    test('when() invokes success callback with data', () {
      const result = Success(42);

      final value = result.when(
        success: (data) => 'got $data',
        failure: (f) => 'failed',
      );

      expect(value, 'got 42');
    });

    /// getOrElse returns the wrapped data without calling the fallback.
    test('getOrElse() returns data', () {
      const result = Success('hello');

      final value = result.getOrElse((f) => 'fallback');

      expect(value, 'hello');
    });

    /// getOrNull returns the wrapped data (not null).
    test('getOrNull() returns data', () {
      const result = Success('hello');

      expect(result.getOrNull(), 'hello');
    });

    /// isSuccess is true for Success.
    test('isSuccess is true', () {
      const result = Success(1);

      expect(result.isSuccess, isTrue);
    });

    /// isFailure is false for Success.
    test('isFailure is false', () {
      const result = Success(1);

      expect(result.isFailure, isFalse);
    });

    /// map transforms the wrapped value.
    test('map() transforms the success value', () {
      const result = Success(10);

      final mapped = result.map((data) => data * 2);

      expect(mapped, const Success(20));
    });

    /// flatMap chains operations that return Result.
    test('flatMap() chains a result-producing operation', () {
      const result = Success(5);

      final chained = result.flatMap((data) => Success(data + 1));

      expect(chained, const Success(6));
    });

    /// flatMap can produce an Err from a Success input.
    test('flatMap() can produce an Err', () {
      const result = Success(5);

      final chained = result.flatMap<int>(
        (data) => const Err(NotFound()),
      );

      expect(chained.isFailure, isTrue);
    });

    /// Two Success instances with the same data are equal.
    test('equality holds for identical data', () {
      const a = Success(42);
      const b = Success(42);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    /// Two Success instances with different data are not equal.
    test('inequality for different data', () {
      const a = Success(1);
      const b = Success(2);

      expect(a, isNot(equals(b)));
    });
  });

  /// Tests for [Err].
  group('Err', () {
    /// when() calls the failure branch with the wrapped failure.
    test('when() invokes failure callback with failure', () {
      const result = Err<int>(NotFound());

      final value = result.when(
        success: (data) => 'got $data',
        failure: (f) => 'failed: ${f.message}',
      );

      expect(value, 'failed: Not found');
    });

    /// getOrElse calls the fallback function with the failure.
    test('getOrElse() invokes fallback with failure', () {
      const result = Err<String>(Timeout());

      final value = result.getOrElse((f) => 'fallback');

      expect(value, 'fallback');
    });

    /// getOrNull returns null for Err.
    test('getOrNull() returns null', () {
      const result = Err<String>(Timeout());

      expect(result.getOrNull(), isNull);
    });

    /// isSuccess is false for Err.
    test('isSuccess is false', () {
      const result = Err<int>(NotFound());

      expect(result.isSuccess, isFalse);
    });

    /// isFailure is true for Err.
    test('isFailure is true', () {
      const result = Err<int>(NotFound());

      expect(result.isFailure, isTrue);
    });

    /// map preserves the failure without calling the transform.
    test('map() preserves the failure', () {
      const result = Err<int>(NotFound());

      final mapped = result.map((data) => data * 2);

      expect(mapped.isFailure, isTrue);
      mapped.when(
        success: (_) => fail('should not be success'),
        failure: (f) => expect(f, isA<NotFound>()),
      );
    });

    /// flatMap short-circuits and preserves the failure.
    test('flatMap() short-circuits on failure', () {
      const result = Err<int>(Unauthorized());

      final chained = result.flatMap((data) => Success(data + 1));

      expect(chained.isFailure, isTrue);
      chained.when(
        success: (_) => fail('should not be success'),
        failure: (f) => expect(f, isA<Unauthorized>()),
      );
    });

    /// Two Err instances with the same failure type are equal when the
    /// failure class supports equality (the built-in failures do not
    /// override ==, so we test identity-based equality with const).
    test('equality holds for identical failures', () {
      const a = Err<int>(NotFound());
      const b = Err<int>(NotFound());

      // NotFound is a const constructor, so const instances are identical.
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  /// Tests for [Result] used polymorphically.
  group('Result (polymorphic)', () {
    /// A helper that accepts a Result and extracts via when.
    test('can be assigned to Result<T> type', () {
      Result<int> result = const Success(1);
      expect(result.isSuccess, isTrue);

      result = const Err(Timeout());
      expect(result.isFailure, isTrue);
    });
  });
}
