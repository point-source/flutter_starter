/// Define the contract and default implementation for secure token persistence.
///
/// Authentication tokens (access and refresh) must be stored in an encrypted
/// store so they are not exposed through device backups or file-system access.
/// [ITokenStorage] declares the operations every token-storage strategy must
/// support, while [SecureTokenStorage] fulfils that contract with
/// [FlutterSecureStorage].  A companion Riverpod provider is included so the
/// rest of the application can depend on [ITokenStorage] without coupling to
/// the concrete implementation.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_starter/core/storage/secure_storage_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_storage.g.dart';

/// Declare the contract for persisting authentication tokens.
///
/// Implementations must store an access token and a refresh token, retrieve
/// each independently, and provide a way to remove both at once (e.g. on
/// logout).
abstract interface class ITokenStorage {
  /// Persist [accessToken] and [refreshToken] to secure storage.
  ///
  /// Both values are written in a single logical operation.  Implementations
  /// should ensure that a failure in one write does not leave the store in an
  /// inconsistent state.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Retrieve the persisted access token, or `null` if none exists.
  ///
  /// A `null` return typically indicates the user has not authenticated or
  /// that tokens have been explicitly cleared.
  Future<String?> getAccessToken();

  /// Retrieve the persisted refresh token, or `null` if none exists.
  ///
  /// A `null` return typically indicates the user has not authenticated or
  /// that tokens have been explicitly cleared.
  Future<String?> getRefreshToken();

  /// Remove both tokens from secure storage.
  ///
  /// Call this during logout or when the server indicates that the refresh
  /// token is no longer valid.
  Future<void> clearTokens();
}

/// Store authentication tokens in [FlutterSecureStorage].
///
/// Tokens are written under the keys [_accessTokenKey] and
/// [_refreshTokenKey].  All reads and writes delegate directly to the
/// underlying [FlutterSecureStorage] instance supplied at construction.
class SecureTokenStorage implements ITokenStorage {
  /// Create a [SecureTokenStorage] backed by the given [_storage] instance.
  const SecureTokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  @override
  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  @override
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }
}

/// Create an [ITokenStorage] backed by [FlutterSecureStorage].
///
/// Reads the [secureStorageProvider] to obtain the storage instance and
/// returns a [SecureTokenStorage] wrapping it.  Override this provider in
/// tests to supply a fake or in-memory token store.
@riverpod
ITokenStorage tokenStorage(Ref ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return SecureTokenStorage(secureStorage);
}
