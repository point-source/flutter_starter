/// Retrofit service for {{entity_name.camelCase()}} API endpoints.
///
/// Defines the HTTP contract for {{entity_name.camelCase()}} operations.
/// The generated implementation delegates to [Dio] and handles JSON
/// serialisation via dart_mappable.
library;

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/models/{{entity_name.snakeCase()}}_dto.dart';

part '{{entity_name.snakeCase()}}_service.g.dart';

/// HTTP client for the {{entity_name.camelCase()}} API.
///
/// Each method maps to a single REST endpoint. The generated
/// [_{{entity_name.pascalCase()}}Service] implementation handles request
/// building, body serialisation, and response parsing.
@RestApi(parser: .DartMappable)
abstract class {{entity_name.pascalCase()}}Service {
  /// Create a [{{entity_name.pascalCase()}}Service] backed by the given
  /// [dio] instance.
  factory {{entity_name.pascalCase()}}Service(Dio dio) = _{{entity_name.pascalCase()}}Service;

  /// Retrieve a single {{entity_name.camelCase()}} by its [id].
  @GET('/{{entity_name.paramCase()}}/{id}')
  Future<{{entity_name.pascalCase()}}Dto> getById(@Path('id') String id);

  /// Retrieve all {{entity_name.camelCase()}} items.
  @GET('/{{entity_name.paramCase()}}')
  Future<List<{{entity_name.pascalCase()}}Dto>> getAll();
}
