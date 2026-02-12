/// Represent a {{model_name.pascalCase()}} in the domain layer.
///
/// This entity is the canonical representation of a {{model_name.camelCase()}}
/// throughout the application. It is created by mapping a
/// [{{model_name.pascalCase()}}Dto] from the data layer and consumed by view
/// models and UI widgets. Because it is a value type, two
/// [{{model_name.pascalCase()}}] instances with identical fields are
/// considered equal.
library;

import 'package:dart_mappable/dart_mappable.dart';

part '{{model_name.snakeCase()}}.mapper.dart';

/// A domain entity representing a {{model_name.camelCase()}}.
///
/// Add the fields relevant to this entity and mark optional ones as
/// nullable. Run `dart run build_runner build` after editing to
/// regenerate the mapper.
@MappableClass()
class {{model_name.pascalCase()}} with {{model_name.pascalCase()}}Mappable {
  /// Create a [{{model_name.pascalCase()}}] with the given fields.
  const {{model_name.pascalCase()}}({
    required this.id,
  });

  /// Unique identifier assigned by the server.
  final String id;
}
