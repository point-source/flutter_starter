/// Authentication-specific failure types.
///
/// These failures are returned by [IAuthRepository] methods when an
/// authentication operation fails. Each subtype maps to a specific error
/// condition so that the UI layer can display targeted messages or take
/// appropriate recovery actions.
library;

import 'package:flutter_starter/core/error/failures.dart';

/// Base class for all authentication failures.
///
/// Extend this class to add new auth-specific failure cases. The sealed
/// hierarchy ensures exhaustive pattern matching in the UI layer.
sealed class AuthFailure extends Failure {
  /// Create an [AuthFailure] with a [message] and optional [stackTrace].
  const AuthFailure(super.message, [super.stackTrace]);
}

/// The provided email/password combination is incorrect.
final class InvalidCredentials extends AuthFailure {
  /// Create an [InvalidCredentials] failure.
  const InvalidCredentials([StackTrace? stackTrace])
      : super('Invalid email or password', stackTrace);
}

/// A user account with the given email already exists.
final class EmailAlreadyInUse extends AuthFailure {
  /// Create an [EmailAlreadyInUse] failure.
  const EmailAlreadyInUse([StackTrace? stackTrace])
      : super('An account with this email already exists', stackTrace);
}

/// The user's session has expired and re-authentication is required.
final class SessionExpired extends AuthFailure {
  /// Create a [SessionExpired] failure.
  const SessionExpired([StackTrace? stackTrace])
      : super('Your session has expired, please log in again', stackTrace);
}

/// An unexpected server-side error occurred during authentication.
final class AuthServerError extends AuthFailure {
  /// Create an [AuthServerError] failure with an optional detail [message].
  const AuthServerError([String message = 'Authentication server error',
      StackTrace? stackTrace])
      : super(message, stackTrace);
}
