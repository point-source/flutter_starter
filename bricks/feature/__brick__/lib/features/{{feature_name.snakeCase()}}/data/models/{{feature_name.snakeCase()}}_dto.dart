/// Data transfer object for {{feature_name.camelCase()}} data returned by the API.
///
/// This DTO mirrors the JSON shape returned by the server. Use the
/// [{{feature_name.pascalCase()}}DtoMapper] extension to convert it to a
/// domain [{{feature_name.pascalCase()}}] entity.
library;

import 'package:dart_mappable/dart_mappable.dart';

part '{{feature_name.snakeCase()}}_dto.mapper.dart';

/// Server representation of a {{feature_name.camelCase()}}.
///
/// Deserialized from JSON responses and converted to a domain
/// [{{feature_name.pascalCase()}}] entity via
/// [{{feature_name.pascalCase()}}DtoMapper.toDomain].
@MappableClass()
class {{feature_name.pascalCase()}}Dto with {{feature_name.pascalCase()}}DtoMappable {
  /// Create a [{{feature_name.pascalCase()}}Dto] from API response fields.
  const {{feature_name.pascalCase()}}Dto({
    required this.id,
  });

  /// Unique identifier assigned by the server.
  final String id;
}
