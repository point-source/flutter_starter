/// Tests for REST endpoint validation installed with the Dio capability.
library;

import 'package:flutter_starter/core/http/rest_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RestConfig.validateApiBaseUrl', () {
    test('accepts absolute HTTP and HTTPS endpoints', () {
      expect(
        RestConfig.validateApiBaseUrl('http://localhost:3000'),
        'http://localhost:3000',
      );
      expect(
        RestConfig.validateApiBaseUrl('https://api.example.com/v1'),
        'https://api.example.com/v1',
      );
    });

    test('rejects a missing endpoint with actionable setup instructions', () {
      expect(
        () => RestConfig.validateApiBaseUrl(''),
        throwsA(
          isA<StateError>()
              .having(
                (error) => error.message,
                'message',
                contains('REST_API_URL'),
              )
              .having(
                (error) => error.message,
                'message',
                contains('--dart-define-from-file'),
              ),
        ),
      );
    });

    test('rejects non-HTTP and relative endpoints', () {
      for (final value in ['api.example.com', '/v1', 'ftp://example.com']) {
        expect(
          () => RestConfig.validateApiBaseUrl(value),
          throwsA(isA<StateError>()),
        );
      }
    });
  });
}
