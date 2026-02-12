/// Tests for [{{feature_name.pascalCase()}}Repository].
///
/// Validates that the repository correctly delegates to
/// [{{feature_name.pascalCase()}}Service], maps responses to domain entities,
/// and converts HTTP errors to the appropriate failure types.
// ignore_for_file: no-empty-block

library;

import 'package:dio/dio.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/core/error/failures.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/models/{{feature_name.snakeCase()}}_dto.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/repositories/{{feature_name.snakeCase()}}_repository.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/failures/{{feature_name.snakeCase()}}_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late Mock{{feature_name.pascalCase()}}Service mockService;
  late {{feature_name.pascalCase()}}Repository repository;

  /// Reusable test data.
  const testDto = {{feature_name.pascalCase()}}Dto(id: 'test-1');

  setUp(() {
    mockService = Mock{{feature_name.pascalCase()}}Service();
    repository = {{feature_name.pascalCase()}}Repository(mockService);
  });

  /// Tests for [{{feature_name.pascalCase()}}Repository.getById].
  group('getById', () {
    /// Returns a [Success] containing the mapped entity on a successful
    /// API response.
    test('returns Success with entity on success', () async {
      when(
        () => mockService.getById(any()),
      ).thenAnswer((_) async => testDto);

      final result = await repository.getById('test-1');

      expect(result.isSuccess, isTrue);
      final entity = result.getOrNull();
      expect(entity, isNotNull);
      expect(entity!.id, 'test-1');
    });

    /// Returns an [Err] with [{{feature_name.pascalCase()}}NotFound] when the
    /// server responds with a 404 status code.
    test('returns Err with NotFound on 404', () async {
      when(() => mockService.getById(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          error: const ServerException('Not found', statusCode: 404),
        ),
      );

      final result = await repository.getById('missing-id');

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('should not succeed'),
        failure: (f) => expect(f, isA<{{feature_name.pascalCase()}}NotFound>()),
      );
    });

    /// Returns an [Err] with [{{feature_name.pascalCase()}}ServerError] for
    /// non-404 server errors.
    test('returns Err with ServerError on generic server error', () async {
      when(() => mockService.getById(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          error: const ServerException('Internal error', statusCode: 500),
        ),
      );

      final result = await repository.getById('test-1');

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('should not succeed'),
        failure: (f) => expect(f, isA<{{feature_name.pascalCase()}}ServerError>()),
      );
    });

    /// Returns an [Err] with [UnexpectedFailure] for non-Dio exceptions.
    test('returns Err with UnexpectedFailure on unexpected exception', () async {
      when(
        () => mockService.getById(any()),
      ).thenThrow(Exception('something broke'));

      final result = await repository.getById('test-1');

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('should not succeed'),
        failure: (f) => expect(f, isA<UnexpectedFailure>()),
      );
    });
  });

  /// Tests for [{{feature_name.pascalCase()}}Repository.getAll].
  group('getAll', () {
    /// Returns a [Success] containing the mapped entities on a successful
    /// API response.
    test('returns Success with entities on success', () async {
      when(
        () => mockService.getAll(),
      ).thenAnswer((_) async => [testDto]);

      final result = await repository.getAll();

      expect(result.isSuccess, isTrue);
      final entities = result.getOrNull();
      expect(entities, isNotNull);
      expect(entities!.length, 1);
      expect(entities.first.id, 'test-1');
    });

    /// Returns a [Success] with an empty list when no items exist.
    test('returns Success with empty list when no items', () async {
      when(
        () => mockService.getAll(),
      ).thenAnswer((_) async => <{{feature_name.pascalCase()}}Dto>[]);

      final result = await repository.getAll();

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), isEmpty);
    });

    /// Returns an [Err] with [{{feature_name.pascalCase()}}ServerError] on
    /// server error.
    test('returns Err with ServerError on server error', () async {
      when(() => mockService.getAll()).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          error: const ServerException('Internal error', statusCode: 500),
        ),
      );

      final result = await repository.getAll();

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('should not succeed'),
        failure: (f) => expect(f, isA<{{feature_name.pascalCase()}}ServerError>()),
      );
    });

    /// Returns an [Err] with [UnexpectedFailure] for non-Dio exceptions.
    test('returns Err with UnexpectedFailure on unexpected exception', () async {
      when(
        () => mockService.getAll(),
      ).thenThrow(Exception('something broke'));

      final result = await repository.getAll();

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('should not succeed'),
        failure: (f) => expect(f, isA<UnexpectedFailure>()),
      );
    });
  });
}
