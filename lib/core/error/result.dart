/// Represents the outcome of an operation that can either succeed or fail.
///
/// Use [Result] as the return type for any operation that might fail in an
/// expected way (network errors, validation failures, etc.). This makes
/// failure handling explicit in the type system, unlike exceptions which
/// are invisible in function signatures.
///
/// ```dart
/// Future<Result<User>> login(String email, String password) async {
///   try {
///     final user = await api.login(email, password);
///     return Success(user);
///   } on DioException catch (e) {
///     return Err(ServerFailure.fromDioException(e));
///   }
/// }
/// ```
///
/// See also:
/// - [Failure] for the error hierarchy
/// - [Success] for successful outcomes
/// - [Err] for failure outcomes
library;

import 'package:flutter/foundation.dart' show immutable;

import 'package:flutter_starter/core/error/failures.dart';

/// A type that represents either a successful value of type [T] or a [Failure].
///
/// This is the core error-handling primitive. All repository methods should
/// return `Future<Result<T>>` instead of throwing exceptions.
sealed class Result<T> {
  /// Creates a [Result] instance.
  const Result();

  /// Pattern-matches on the result, calling [success] or [failure] depending
  /// on whether this is a [Success] or [Err].
  ///
  /// ```dart
  /// final message = result.when(
  ///   success: (user) => 'Welcome, ${user.name}',
  ///   failure: (f) => 'Error: ${f.message}',
  /// );
  /// ```
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  });

  /// Transforms the success value using [transform], leaving failures untouched.
  ///
  /// ```dart
  /// final nameResult = userResult.map((user) => user.name);
  /// ```
  Result<R> map<R>(R Function(T data) transform);

  /// Chains a result-producing operation on the success value.
  ///
  /// Unlike [map], the [transform] function itself returns a [Result],
  /// allowing sequential operations that can each fail independently.
  ///
  /// ```dart
  /// final profileResult = userResult.flatMap(
  ///   (user) => profileRepo.getProfile(user.id),
  /// );
  /// ```
  Result<R> flatMap<R>(Result<R> Function(T data) transform);

  /// Returns the success value, or the result of [orElse] if this is a failure.
  T getOrElse(T Function(Failure failure) orElse);

  /// Returns the success value, or `null` if this is a failure.
  T? getOrNull();

  /// Whether this result represents a successful outcome.
  bool get isSuccess;

  /// Whether this result represents a failure.
  bool get isFailure;

  /// Return the success value or throw a [FailureException].
  ///
  /// Useful inside try/catch blocks where failures should propagate
  /// as exceptions (e.g. inside [TaskTracker] work functions).
  ///
  /// ```dart
  /// final user = (await repo.getUser(id)).getOrThrow();
  /// ```
  T getOrThrow();

  /// Return the [Failure] if this is an [Err], or `null` if [Success].
  Failure? get failureOrNull;
}

/// A successful [Result] containing a [data] value of type [T].
@immutable
final class Success<T> extends Result<T> {
  /// Creates a successful result with the given [data].
  const Success(this.data);

  /// The success value.
  final T data;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) => success(data);

  @override
  Result<R> map<R>(R Function(T data) transform) => Success(transform(data));

  @override
  Result<R> flatMap<R>(Result<R> Function(T data) transform) => transform(data);

  @override
  T getOrElse(T Function(Failure failure) orElse) => data;

  @override
  T? getOrNull() => data;

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;

  @override
  T getOrThrow() => data;

  @override
  Failure? get failureOrNull => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Success<T> && data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// A failed [Result] containing a [Failure].
@immutable
final class Err<T> extends Result<T> {
  /// Creates a failed result with the given [failure].
  const Err(this.failure);

  /// The failure describing what went wrong.
  final Failure failure;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) => failure(this.failure);

  @override
  Result<R> map<R>(R Function(T data) transform) => Err(failure);

  @override
  Result<R> flatMap<R>(Result<R> Function(T data) transform) => Err(failure);

  @override
  T getOrElse(T Function(Failure failure) orElse) => orElse(failure);

  @override
  T? getOrNull() => null;

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;

  @override
  T getOrThrow() => throw FailureException(failure);

  @override
  // ignore: match-getter-setter-field-names
  Failure get failureOrNull => failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Err<T> && failure == other.failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Err($failure)';
}
