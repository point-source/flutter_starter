/// Represent a {{feature_name.pascalCase()}} in the domain layer.
///
/// This entity is the canonical representation of a {{feature_name.camelCase()}}
/// throughout the application. Repository implementations create it from
/// their selected data source, and view models and UI widgets consume it.
/// Because it is a value type, two [{{feature_name.pascalCase()}}] instances
/// with identical fields are considered equal.
library;

import 'package:dart_mappable/dart_mappable.dart';

part '{{feature_name.snakeCase()}}.mapper.dart';

/// A domain entity representing a {{feature_name.camelCase()}}.
///
/// Add the fields relevant to this feature and mark optional ones as
/// nullable. Run `dart run build_runner build` after editing to
/// regenerate the mapper.
@MappableClass()
class {{feature_name.pascalCase()}} with {{feature_name.pascalCase()}}Mappable {
  /// Create a [{{feature_name.pascalCase()}}] with the given fields.
  const {{feature_name.pascalCase()}}({
    required this.id,
  });

  /// Unique identifier assigned by the selected data source.
  final String id;
}
