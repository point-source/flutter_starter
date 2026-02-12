/// Tests for [SecureTokenStorage].
///
/// Validates that the storage implementation correctly delegates read, write,
/// and delete operations to [FlutterSecureStorage] using the expected key
/// names.
// ignore_for_file: no-empty-block

library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_starter/core/storage/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// Mock implementation of [FlutterSecureStorage].
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureTokenStorage tokenStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    tokenStorage = SecureTokenStorage(mockStorage);
  });

  /// Tests for [SecureTokenStorage.saveTokens].
  group('saveTokens', () {
    /// Writes both access and refresh tokens to secure storage.
    test('writes both tokens to secure storage', () async {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      await tokenStorage.saveTokens(
        accessToken: 'access-123',
        refreshToken: 'refresh-456',
      );

      verify(
        () => mockStorage.write(key: 'access_token', value: 'access-123'),
      ).called(1);
      verify(
        () => mockStorage.write(key: 'refresh_token', value: 'refresh-456'),
      ).called(1);
    });
  });

  /// Tests for [SecureTokenStorage.getAccessToken].
  group('getAccessToken', () {
    /// Returns the stored access token when it exists.
    test('returns stored access token', () async {
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => 'access-123');

      final result = await tokenStorage.getAccessToken();

      expect(result, 'access-123');
      verify(() => mockStorage.read(key: 'access_token')).called(1);
    });

    /// Returns null when no access token is stored.
    test('returns null when no token stored', () async {
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);

      final result = await tokenStorage.getAccessToken();

      expect(result, isNull);
      verify(() => mockStorage.read(key: 'access_token')).called(1);
    });
  });

  /// Tests for [SecureTokenStorage.getRefreshToken].
  group('getRefreshToken', () {
    /// Returns the stored refresh token when it exists.
    test('returns stored refresh token', () async {
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => 'refresh-456');

      final result = await tokenStorage.getRefreshToken();

      expect(result, 'refresh-456');
      verify(() => mockStorage.read(key: 'refresh_token')).called(1);
    });

    /// Returns null when no refresh token is stored.
    test('returns null when no token stored', () async {
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);

      final result = await tokenStorage.getRefreshToken();

      expect(result, isNull);
      verify(() => mockStorage.read(key: 'refresh_token')).called(1);
    });
  });

  /// Tests for [SecureTokenStorage.clearTokens].
  group('clearTokens', () {
    /// Deletes both access and refresh tokens from secure storage.
    test('deletes both tokens from secure storage', () async {
      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      await tokenStorage.clearTokens();

      verify(() => mockStorage.delete(key: 'access_token')).called(1);
      verify(() => mockStorage.delete(key: 'refresh_token')).called(1);
    });
  });
}
