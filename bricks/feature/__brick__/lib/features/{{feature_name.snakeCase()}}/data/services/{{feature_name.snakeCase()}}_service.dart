/// Retrofit service for {{feature_name.camelCase()}} API endpoints.
///
/// Defines the HTTP contract for {{feature_name.camelCase()}} operations.
/// The generated implementation delegates to [Dio] and handles JSON
/// serialisation via dart_mappable.
library;

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/models/{{feature_name.snakeCase()}}_dto.dart';

part '{{feature_name.snakeCase()}}_service.g.dart';

/// HTTP client for the {{feature_name.camelCase()}} API.
///
/// Each method maps to a single REST endpoint. The generated
/// [_{{feature_name.pascalCase()}}Service] implementation handles request
/// building, body serialisation, and response parsing.
@RestApi()
abstract class {{feature_name.pascalCase()}}Service {
  /// Create a [{{feature_name.pascalCase()}}Service] backed by the given
  /// [dio] instance.
  factory {{feature_name.pascalCase()}}Service(Dio dio) = _{{feature_name.pascalCase()}}Service;

  /// Retrieve a single {{feature_name.camelCase()}} by its [id].
  @GET('/{{feature_name.paramCase()}}/{id}')
  Future<{{feature_name.pascalCase()}}Dto> getById(@Path('id') String id);

  /// Retrieve all {{feature_name.camelCase()}} items.
  @GET('/{{feature_name.paramCase()}}')
  Future<List<{{feature_name.pascalCase()}}Dto>> getAll();
}
