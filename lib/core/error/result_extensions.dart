/// Extensions on [Result] for common narrowing and mapping patterns.
///
/// These reduce boilerplate when chaining [Result] operations that
/// involve null checks or mapped null checks.
library;

import 'package:flutter_starter/core/error/failures.dart';
import 'package:flutter_starter/core/error/result.dart';

/// Narrow a [Result] with a nullable success value to non-nullable.
///
/// ```dart
/// final result = Success<User?>(null);
/// final narrowed = result.notNull(() => const AuthServerError('No user'));
/// // narrowed is Err(AuthServerError('No user'))
/// ```
extension ResultNullCheck<T> on Result<T?> {
  /// Return [Err] with the given [Failure] if the success value is `null`.
  Result<T> notNull(Failure Function() onNull) =>
      flatMap((v) => v != null ? Success(v) : Err(onNull()));
}

/// Map a [Result] value and null-check the output in one step.
///
/// ```dart
/// final userResult = Success(response);
/// final emailResult = userResult.mapNotNull(
///   (r) => r.email,
///   () => const AuthServerError('Email is missing'),
/// );
/// ```
extension ResultMapNotNull<T> on Result<T> {
  /// Apply [transform] to the success value and return [Err] if the
  /// result is `null`.
  Result<R> mapNotNull<R>(
    R? Function(T data) transform,
    Failure Function() onNull,
  ) => flatMap((v) {
    final mapped = transform(v);
    return mapped != null ? Success(mapped) : Err(onNull());
  });
}
