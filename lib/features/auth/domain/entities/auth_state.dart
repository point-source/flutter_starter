/// Represent the current authentication state.
///
/// Use the named factories to create the appropriate variant and read
/// [isAuthenticated] / [user] to inspect the state without pattern matching.
library;

import 'package:flutter_starter/features/auth/domain/entities/user.dart';

/// Value type representing the current authentication state.
///
/// Shared across features via [authStateRepoProvider]. Use the named
/// factories to create the appropriate variant.
class AuthState {
  /// Create an [AuthState] with the given authentication status.
  const AuthState._({required this.isAuthenticated, this.user});

  /// Create an [AuthState] for a fresh session with no check performed.
  factory AuthState.initial() => const AuthState._(isAuthenticated: false);

  /// Create an [AuthState] for an authenticated session with [user].
  factory AuthState.authenticated(User user) =>
      AuthState._(user: user, isAuthenticated: true);

  /// Create an [AuthState] for an unauthenticated (logged-out) session.
  factory AuthState.unauthenticated() =>
      const AuthState._(isAuthenticated: false);

  /// Whether the user is currently authenticated.
  final bool isAuthenticated;

  /// The authenticated user's profile, or `null` if unauthenticated.
  final User? user;
}
