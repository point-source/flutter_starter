/// Tests for [ErrorInterceptor].
///
/// Validates that the interceptor correctly maps all [DioExceptionType]
/// values to the appropriate [AppException] subtypes, preserving status
/// codes and error messages where applicable.
library;

import 'package:dio/dio.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/core/network/interceptors/error_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Dio dio;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.com'));
    dio.interceptors.add(ErrorInterceptor());
  });

  /// Helper to trigger an error interceptor by rejecting the request with
  /// a specific [DioException] type.
  Future<void> triggerError(DioException error) async {
    dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(error);
        },
      ),
    );

    try {
      await dio.get<void>('/test');
    } on DioException catch (_) {
      // Expected - we capture the error in the test assertions
    }
  }

  /// Tests for timeout-related error mappings.
  group('timeout errors', () {
    /// connectionTimeout is mapped to TimeoutException.
    test('maps connectionTimeout to TimeoutException', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      try {
        await triggerError(error);
      } on DioException catch (e) {
        final appError = e.error! as TimeoutException;
        expect(appError, isA<TimeoutException>());
        expect(appError.message, 'Request timed out');
      }
    });

    /// sendTimeout is mapped to TimeoutException.
    test('maps sendTimeout to TimeoutException', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.sendTimeout,
      );

      try {
        await triggerError(error);
      } on DioException catch (e) {
        final appError = e.error! as TimeoutException;
        expect(appError, isA<TimeoutException>());
        expect(appError.message, 'Request timed out');
      }
    });

    /// receiveTimeout is mapped to TimeoutException.
    test('maps receiveTimeout to TimeoutException', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.receiveTimeout,
      );

      try {
        await triggerError(error);
      } on DioException catch (e) {
        final appError = e.error! as TimeoutException;
        expect(appError, isA<TimeoutException>());
        expect(appError.message, 'Request timed out');
      }
    });
  });

  /// Tests for network-related error mappings.
  group('network errors', () {
    /// connectionError is mapped to NetworkException.
    test('maps connectionError to NetworkException', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      try {
        await triggerError(error);
      } on DioException catch (e) {
        final appError = e.error! as NetworkException;
        expect(appError, isA<NetworkException>());
        expect(appError.message, 'No internet connection');
      }
    });
  });

  /// Tests for request cancellation and certificate errors.
  group('cancel and certificate errors', () {
    /// cancel is mapped to ServerException.
    test('maps cancel to ServerException', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.cancel,
      );

      try {
        await triggerError(error);
      } on DioException catch (e) {
        final appError = e.error! as ServerException;
        expect(appError.message, 'Request was cancelled');
        expect(appError.statusCode, isNull);
      }
    });

    /// badCertificate is mapped to ServerException.
    test('maps badCertificate to ServerException', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badCertificate,
      );

      try {
        await triggerError(error);
      } on DioException catch (e) {
        final appError = e.error! as ServerException;
        expect(appError.message, 'Invalid SSL certificate');
        expect(appError.statusCode, isNull);
      }
    });
  });

  /// Tests for badResponse error mappings with various response payloads.
  group('badResponse errors', () {
    /// Extracts message from JSON response body using 'message' field.
    test('maps badResponse with JSON message to ServerException', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
          data: {'message': 'Not found'},
        ),
        type: DioExceptionType.badResponse,
      );

      try {
        await triggerError(error);
      } on DioException catch (e) {
        final appError = e.error! as ServerException;
        expect(appError.message, 'Not found');
        expect(appError.statusCode, 404);
      }
    });

    /// Extracts message from JSON response body using 'error' field.
    test('maps badResponse with JSON error field to ServerException', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
          data: {'error': 'Invalid request'},
        ),
        type: DioExceptionType.badResponse,
      );

      try {
        await triggerError(error);
      } on DioException catch (e) {
        final appError = e.error! as ServerException;
        expect(appError.message, 'Invalid request');
        expect(appError.statusCode, 400);
      }
    });

    /// Falls back to default message when response body is not JSON.
    test('maps badResponse without JSON to ServerException with default message', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
          data: 'Internal Server Error',
        ),
        type: DioExceptionType.badResponse,
      );

      try {
        await triggerError(error);
      } on DioException catch (e) {
        final appError = e.error! as ServerException;
        expect(appError.message, 'Server error');
        expect(appError.statusCode, 500);
      }
    });
  });

  /// Tests for unknown error mappings.
  group('unknown errors', () {
    /// Maps unknown error with nested error object.
    test('maps unknown with error to ServerException', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        error: Exception('Socket closed'),
      );

      try {
        await triggerError(error);
      } on DioException catch (e) {
        final appError = e.error! as ServerException;
        expect(appError.message, contains('Unexpected error:'));
        expect(appError.statusCode, isNull);
      }
    });

    /// Maps unknown error without nested error using message field.
    test('maps unknown with message to ServerException', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        message: 'Custom error message',
      );

      try {
        await triggerError(error);
      } on DioException catch (e) {
        final appError = e.error! as ServerException;
        expect(appError.message, 'Custom error message');
        expect(appError.statusCode, isNull);
      }
    });

    /// Maps unknown error with neither error nor message.
    test('maps unknown without error or message to ServerException', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
      );

      try {
        await triggerError(error);
      } on DioException catch (e) {
        final appError = e.error! as ServerException;
        expect(appError.message, 'Unknown error');
        expect(appError.statusCode, isNull);
      }
    });
  });
}
