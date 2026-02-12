/// Map [{{model_name.pascalCase()}}Dto] to the domain [{{model_name.pascalCase()}}] entity.
///
/// This extension keeps mapping logic close to the DTO while allowing
/// the domain layer to remain free of data-layer dependencies.
library;

import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/models/{{model_name.snakeCase()}}_dto.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/entities/{{model_name.snakeCase()}}.dart';

/// Add a [toDomain] conversion method to [{{model_name.pascalCase()}}Dto].
///
/// Used by the repository to translate API responses into domain entities
/// before returning them to the view model layer.
extension {{model_name.pascalCase()}}DtoMapper on {{model_name.pascalCase()}}Dto {
  /// Convert this [{{model_name.pascalCase()}}Dto] to a domain
  /// [{{model_name.pascalCase()}}] entity.
  {{model_name.pascalCase()}} toDomain() {
    return {{model_name.pascalCase()}}(
      id: id,
    );
  }
}
