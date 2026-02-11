/// Map [{{feature_name.pascalCase()}}Dto] to the domain [{{feature_name.pascalCase()}}] entity.
///
/// This extension keeps mapping logic close to the DTO while allowing
/// the domain layer to remain free of data-layer dependencies.
library;

import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/models/{{feature_name.snakeCase()}}_dto.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}.dart';

/// Add a [toDomain] conversion method to [{{feature_name.pascalCase()}}Dto].
///
/// Used by the repository to translate API responses into domain entities
/// before returning them to the view model layer.
extension {{feature_name.pascalCase()}}DtoMapper on {{feature_name.pascalCase()}}Dto {
  /// Convert this [{{feature_name.pascalCase()}}Dto] to a domain
  /// [{{feature_name.pascalCase()}}] entity.
  {{feature_name.pascalCase()}} toDomain() {
    return {{feature_name.pascalCase()}}(
      id: id,
    );
  }
}
