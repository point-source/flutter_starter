/// Data transfer object for {{model_name.camelCase()}} data returned by the API.
///
/// This DTO mirrors the JSON shape returned by the server. Use the
/// [{{model_name.pascalCase()}}DtoMapper] extension to convert it to a
/// domain [{{model_name.pascalCase()}}] entity.
library;

import 'package:dart_mappable/dart_mappable.dart';

part '{{model_name.snakeCase()}}_dto.mapper.dart';

/// Server representation of a {{model_name.camelCase()}}.
///
/// Deserialized from JSON responses and converted to a domain
/// [{{model_name.pascalCase()}}] entity via
/// [{{model_name.pascalCase()}}DtoMapper.toDomain].
@MappableClass()
class {{model_name.pascalCase()}}Dto with {{model_name.pascalCase()}}DtoMappable {
  /// Create a [{{model_name.pascalCase()}}Dto] from API response fields.
  const {{model_name.pascalCase()}}Dto({
    required this.id,
  });

  /// Unique identifier assigned by the server.
  final String id;
}
