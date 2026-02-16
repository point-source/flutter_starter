/// Retrofit service for {{service_name.camelCase()}} API endpoints.
///
/// Defines the HTTP contract for {{service_name.camelCase()}} operations.
/// The generated implementation delegates to [Dio] and handles JSON
/// serialisation via dart_mappable.
library;

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part '{{service_name.snakeCase()}}_service.g.dart';

/// HTTP client for the {{service_name.camelCase()}} API.
///
/// Each method maps to a single REST endpoint. The generated
/// [_{{service_name.pascalCase()}}Service] implementation handles request
/// building, body serialisation, and response parsing.
///
/// Add imports for request/response DTOs and update the return types
/// below once the corresponding models are created.
@RestApi(parser: .DartMappable)
abstract class {{service_name.pascalCase()}}Service {
  /// Create a [{{service_name.pascalCase()}}Service] backed by the given
  /// [dio] instance.
  factory {{service_name.pascalCase()}}Service(Dio dio) = _{{service_name.pascalCase()}}Service;

  // TODO: Add endpoint methods. Examples:
  //
  // /// Retrieve a single item by its [id].
  // @GET('/{{service_name.paramCase()}}/{id}')
  // Future<SomeDto> getById(@Path('id') String id);
  //
  // /// Retrieve all items.
  // @GET('/{{service_name.paramCase()}}')
  // Future<List<SomeDto>> getAll();
}
