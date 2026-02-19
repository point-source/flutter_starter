/// Implement [I{{entity_name.pascalCase()}}Repository] using the REST API.
///
/// This is the concrete data-layer implementation of the
/// {{entity_name.camelCase()}} repository contract. It delegates network
/// calls to [{{entity_name.pascalCase()}}Service] and maps all outcomes
/// into [Result] values.
library;

import 'package:dio/dio.dart';

import 'package:flutter_starter/core/http/dio_api_exception.dart';
import 'package:flutter_starter/core/error/failures.dart';
import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/core/logging/app_logger.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/mappers/{{entity_name.snakeCase()}}_mapper.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/services/{{entity_name.snakeCase()}}_service.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/entities/{{entity_name.snakeCase()}}.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/repositories/i_{{entity_name.snakeCase()}}_repository.dart';

/// REST-backed implementation of [I{{entity_name.pascalCase()}}Repository].
///
/// Wraps every service call in try/catch and returns [Result] values.
/// On success, DTOs are mapped to domain entities. On failure,
/// [DioException] errors are mapped to appropriate failures.
class {{entity_name.pascalCase()}}Repository implements I{{entity_name.pascalCase()}}Repository {
  /// Create a [{{entity_name.pascalCase()}}Repository] with the given
  /// [{{entity_name.camelCase()}}Service] and [logger].
  const {{entity_name.pascalCase()}}Repository(this._service, this._logger);

  final {{entity_name.pascalCase()}}Service _service;
  final IAppLogger _logger;

  @override
  Future<Result<{{entity_name.pascalCase()}}>> getById(String id) async {
    try {
      final dto = await _service.getById(id);
      return Success(dto.toDomain());
    } on DioException catch (e, st) {
      return Err(_mapDioException(e, st));
    } on Exception catch (e, st) {
      _logger.error(
        'Unexpected error in {{entity_name.camelCase()}} repository',
        error: e,
        stackTrace: st,
        tag: '{{feature_name.snakeCase()}}',
      );
      return Err(UnexpectedFailure(e, st));
    }
  }

  @override
  Future<Result<List<{{entity_name.pascalCase()}}>>> getAll() async {
    try {
      final dtos = await _service.getAll();
      return Success(dtos.map((dto) => dto.toDomain()).toList());
    } on DioException catch (e, st) {
      return Err(_mapDioException(e, st));
    } on Exception catch (e, st) {
      _logger.error(
        'Unexpected error in {{entity_name.camelCase()}} repository',
        error: e,
        stackTrace: st,
        tag: '{{feature_name.snakeCase()}}',
      );
      return Err(UnexpectedFailure(e, st));
    }
  }

  /// Map a [DioException] to an appropriate [Failure].
  ///
  /// The [ErrorInterceptor] wraps the original error as an [DioApiException]
  /// inside [DioException.error], preserving the HTTP status code.
  Failure _mapDioException(DioException e, StackTrace st) {
    final error = e.error;
    if (error is DioApiException) {
      return switch (error.statusCode) {
        404 => NotFound(st),
        _ => BadResponse(error.statusCode ?? 0, error.message, st),
      };
    }
    return UnexpectedFailure(e, st);
  }
}
