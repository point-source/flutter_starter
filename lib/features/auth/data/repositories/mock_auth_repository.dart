/// Fake [IAuthRepository] for development without a backend.
///
/// Returns a hard-coded [User] for all auth operations, with no network
/// calls or token storage. Activated when `AUTH_BYPASS=mock` is set in
/// the compile-time config.
library;

import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/features/auth/domain/entities/user.dart';
import 'package:flutter_starter/features/auth/domain/repositories/i_auth_repository.dart';

/// [IAuthRepository] implementation that returns a fake user immediately.
///
/// Useful for UI and navigation development when no backend is available.
class MockAuthRepository implements IAuthRepository {
  /// Create a [MockAuthRepository].
  const MockAuthRepository();

  static const _mockUser = User(
    id: 'mock-user-001',
    email: 'dev@example.com',
    name: 'Dev User',
  );

  @override
  Future<Result<User>> login(String email, String password) async =>
      const Success(_mockUser);

  @override
  Future<Result<User>> register({
    required String email,
    required String password,
    required String name,
  }) async => Success(User(id: 'mock-user-001', email: email, name: name));

  @override
  Future<Result<void>> logout() async => const Success(null);

  @override
  Future<Result<User?>> getCurrentUser() async => const Success(_mockUser);
}
