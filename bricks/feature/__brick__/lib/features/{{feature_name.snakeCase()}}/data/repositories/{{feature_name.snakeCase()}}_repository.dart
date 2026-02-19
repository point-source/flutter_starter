{{#dio}}/// Implement [I{{feature_name.pascalCase()}}Repository] using the REST API.
///
/// This is the concrete data-layer implementation of the
/// {{feature_name.camelCase()}} repository contract. It delegates network
/// calls to [{{feature_name.pascalCase()}}Service] and maps all outcomes
/// into [Result] values with feature-specific
/// [{{feature_name.pascalCase()}}Failure] types.
library;

import 'package:dio/dio.dart';

import 'package:flutter_starter/core/http/dio_api_exception.dart';
import 'package:flutter_starter/core/error/failures.dart';
import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/core/logging/app_logger.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/mappers/{{feature_name.snakeCase()}}_mapper.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/services/{{feature_name.snakeCase()}}_service.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/failures/{{feature_name.snakeCase()}}_failure.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/repositories/i_{{feature_name.snakeCase()}}_repository.dart';

/// REST-backed implementation of [I{{feature_name.pascalCase()}}Repository].
///
/// Wraps every service call in try/catch and returns [Result] values.
/// On success, DTOs are mapped to domain entities. On failure,
/// [DioException] errors are mapped to the appropriate
/// [{{feature_name.pascalCase()}}Failure] subtype.
class {{feature_name.pascalCase()}}Repository implements I{{feature_name.pascalCase()}}Repository {
  /// Create a [{{feature_name.pascalCase()}}Repository] with the given
  /// [{{feature_name.camelCase()}}Service] and [logger].
  const {{feature_name.pascalCase()}}Repository(this._service, this._logger);

  final {{feature_name.pascalCase()}}Service _service;
  final IAppLogger _logger;

  @override
  Future<Result<{{feature_name.pascalCase()}}>> getById(String id) async {
    try {
      final dto = await _service.getById(id);
      return Success(dto.toDomain());
    } on DioException catch (e, st) {
      return Err(_mapDioException(e, st));
    } on Exception catch (e, st) {
      _logger.error(
        'Unexpected error in {{feature_name.camelCase()}} repository',
        error: e,
        stackTrace: st,
        tag: '{{feature_name.snakeCase()}}',
      );
      return Err(UnexpectedFailure(e, st));
    }
  }

  @override
  Future<Result<List<{{feature_name.pascalCase()}}>>> getAll() async {
    try {
      final dtos = await _service.getAll();
      return Success(dtos.map((dto) => dto.toDomain()).toList());
    } on DioException catch (e, st) {
      return Err(_mapDioException(e, st));
    } on Exception catch (e, st) {
      _logger.error(
        'Unexpected error in {{feature_name.camelCase()}} repository',
        error: e,
        stackTrace: st,
        tag: '{{feature_name.snakeCase()}}',
      );
      return Err(UnexpectedFailure(e, st));
    }
  }

  /// Map a [DioException] to the appropriate
  /// [{{feature_name.pascalCase()}}Failure].
  ///
  /// The [ErrorInterceptor] wraps the original error as an [DioApiException]
  /// inside [DioException.error], preserving the HTTP status code.
  {{feature_name.pascalCase()}}Failure _mapDioException(
    DioException e,
    StackTrace st,
  ) {
    final error = e.error;
    if (error is DioApiException) {
      return switch (error.statusCode) {
        404 => {{feature_name.pascalCase()}}NotFound(st),
        _ => {{feature_name.pascalCase()}}ServerError(error.message, st),
      };
    }
    return {{feature_name.pascalCase()}}ServerError(
      e.message ?? 'Unknown {{feature_name.camelCase()}} error',
      st,
    );
  }
}
{{/dio}}