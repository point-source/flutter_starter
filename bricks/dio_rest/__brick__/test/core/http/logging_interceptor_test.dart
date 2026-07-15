/// Verify REST logs do not expose query values.
library;

import 'package:dio/dio.dart';
import 'package:flutter_starter/core/http/interceptors/logging_interceptor.dart';
import 'package:flutter_starter/core/logging/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLogger extends Mock implements IAppLogger {}

void main() {
  test('logs the request path without query secrets', () async {
    final logger = _MockLogger();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
      ..interceptors.add(RestLoggingInterceptor(logger))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.reject(
            DioException(requestOptions: options, type: .cancel),
          ),
        ),
      );

    await expectLater(
      dio.get<void>('/orders?access_token=secret'),
      throwsA(isA<DioException>()),
    );

    verify(() => logger.debug('GET /orders', tag: 'http')).called(1);
    verifyNever(
      () => logger.debug(
        any(that: contains('secret')),
        tag: any(named: 'tag'),
      ),
    );
  });
}
