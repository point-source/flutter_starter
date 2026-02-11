/// Map [{{entity_name.pascalCase()}}Dto] to the domain [{{entity_name.pascalCase()}}] entity.
///
/// This extension keeps mapping logic close to the DTO while allowing
/// the domain layer to remain free of data-layer dependencies.
library;

import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/models/{{entity_name.snakeCase()}}_dto.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/entities/{{entity_name.snakeCase()}}.dart';

/// Add a [toDomain] conversion method to [{{entity_name.pascalCase()}}Dto].
///
/// Used by the repository to translate API responses into domain entities
/// before returning them to the view model layer.
extension {{entity_name.pascalCase()}}DtoMapper on {{entity_name.pascalCase()}}Dto {
  /// Convert this [{{entity_name.pascalCase()}}Dto] to a domain
  /// [{{entity_name.pascalCase()}}] entity.
  {{entity_name.pascalCase()}} toDomain() {
    return {{entity_name.pascalCase()}}(
      id: id,
    );
  }
}
