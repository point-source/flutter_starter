/// Define the contract for authentication operations.
///
/// This interface sits in the domain layer and is implemented by
/// [AuthRepository] in the data layer. All methods return [Result] so
/// that callers handle failures through the type system rather than
/// catching exceptions.
library;

import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/features/auth/domain/entities/user.dart';

/// Contract for authentication operations.
///
/// Implementations are responsible for communicating with the auth API,
/// persisting tokens, and mapping data-layer models to domain entities.
abstract interface class IAuthRepository {
  /// Authenticate a user with [email] and [password].
  ///
  /// On success the implementation must persist the returned tokens and
  /// return the authenticated [User]. On failure it returns an appropriate
  /// [AuthFailure].
  Future<Result<User>> login(String email, String password);

  /// Create a new user account.
  ///
  /// On success the implementation must persist the returned tokens and
  /// return the newly created [User].
  Future<Result<User>> register({
    required String email,
    required String password,
    required String name,
  });

  /// End the current session.
  ///
  /// The implementation must clear persisted tokens regardless of whether
  /// the server-side logout succeeds.
  Future<Result<void>> logout();

  /// Retrieve the currently authenticated user, or `null` if no valid
  /// session exists.
  ///
  /// Typically used at startup to restore a previous session.
  Future<Result<User?>> getCurrentUser();
}
