/// Data transfer object for {{entity_name.camelCase()}} data returned by the API.
///
/// This DTO mirrors the JSON shape returned by the server. Use the
/// [{{entity_name.pascalCase()}}DtoMapper] extension to convert it to a
/// domain [{{entity_name.pascalCase()}}] entity.
library;

import 'package:dart_mappable/dart_mappable.dart';

part '{{entity_name.snakeCase()}}_dto.mapper.dart';

/// Server representation of a {{entity_name.camelCase()}}.
///
/// Deserialized from JSON responses and converted to a domain
/// [{{entity_name.pascalCase()}}] entity via
/// [{{entity_name.pascalCase()}}DtoMapper.toDomain].
@MappableClass()
class {{entity_name.pascalCase()}}Dto with {{entity_name.pascalCase()}}DtoMappable {
  /// Create a [{{entity_name.pascalCase()}}Dto] from API response fields.
  const {{entity_name.pascalCase()}}Dto({
    required this.id,
  });

  /// Unique identifier assigned by the server.
  final String id;
}
