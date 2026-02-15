/// Tests for [AuthInterceptor].
///
/// Validates that the interceptor correctly attaches Bearer tokens to
/// authenticated requests while skipping public endpoints and requests
/// that already have an Authorization header.
library;

import 'package:dio/dio.dart';
import 'package:flutter_starter/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockTokenStorage mockTokenStorage;
  late Dio dio;

  setUp(() {
    mockTokenStorage = MockTokenStorage();
    dio = Dio(BaseOptions(baseUrl: 'http://test.com'));
    dio.interceptors.add(AuthInterceptor(mockTokenStorage));
  });

  /// Helper to capture the modified request headers without actually
  /// sending the request.
  Future<RequestOptions?> captureRequest(String path) async {
    RequestOptions? capturedOptions;

    // Add a second interceptor to capture the modified request
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedOptions = options;
          // Reject to prevent actual network call
          handler.reject(DioException(requestOptions: options, type: .cancel));
        },
      ),
    );

    try {
      await dio.get<void>(path);
    } on DioException catch (_) {
      // Expected - we only care about capturing the options
    }

    return capturedOptions;
  }

  /// Tests for authenticated requests.
  group('authenticated requests', () {
    /// Adds Bearer token to authenticated requests.
    test('adds Bearer token to authenticated requests', () async {
      when(
        () => mockTokenStorage.getAccessToken(),
      ).thenAnswer((_) async => 'test-token-123');

      final options = await captureRequest('/api/profile');

      expect(options, isNotNull);
      expect(options!.headers['Authorization'], 'Bearer test-token-123');
      verify(() => mockTokenStorage.getAccessToken()).called(1);
    });

    /// Proceeds without token when none is stored.
    test('proceeds without token when none stored', () async {
      when(
        () => mockTokenStorage.getAccessToken(),
      ).thenAnswer((_) async => null);

      final options = await captureRequest('/api/profile');

      expect(options, isNotNull);
      expect(options!.headers['Authorization'], isNull);
      verify(() => mockTokenStorage.getAccessToken()).called(1);
    });

    /// Skips token when Authorization header already set.
    test('skips when Authorization header already set', () async {
      dio.options.headers['Authorization'] = 'Bearer custom-token';

      final options = await captureRequest('/api/profile');

      expect(options, isNotNull);
      expect(options!.headers['Authorization'], 'Bearer custom-token');
      // Should not attempt to read from token storage
      verifyNever(() => mockTokenStorage.getAccessToken());
    });
  });

  /// Tests for public endpoints that should not receive tokens.
  group('public endpoints', () {
    /// Skips token for /auth/login path.
    test('skips token for /auth/login path', () async {
      final options = await captureRequest('/auth/login');

      expect(options, isNotNull);
      expect(options!.headers['Authorization'], isNull);
      verifyNever(() => mockTokenStorage.getAccessToken());
    });

    /// Skips token for /auth/register path.
    test('skips token for /auth/register path', () async {
      final options = await captureRequest('/auth/register');

      expect(options, isNotNull);
      expect(options!.headers['Authorization'], isNull);
      verifyNever(() => mockTokenStorage.getAccessToken());
    });

    /// Skips token when path ends with public endpoint.
    test('skips token when path ends with public endpoint', () async {
      final options = await captureRequest('/api/v1/auth/login');

      expect(options, isNotNull);
      expect(options!.headers['Authorization'], isNull);
      verifyNever(() => mockTokenStorage.getAccessToken());
    });
  });

  /// Tests for error handling when token storage fails.
  group('storage failures', () {
    /// Proceeds without token when storage throws.
    test('proceeds without token when storage throws', () async {
      when(
        () => mockTokenStorage.getAccessToken(),
      ).thenThrow(Exception('Keychain unavailable'));

      final options = await captureRequest('/api/profile');

      expect(options, isNotNull);
      expect(options!.headers['Authorization'], isNull);
      verify(() => mockTokenStorage.getAccessToken()).called(1);
    });
  });
}
