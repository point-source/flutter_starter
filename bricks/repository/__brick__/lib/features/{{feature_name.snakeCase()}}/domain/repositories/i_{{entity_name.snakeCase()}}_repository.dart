/// Define the contract for {{entity_name.camelCase()}} operations.
///
/// This interface sits in the domain layer and is implemented by
/// [{{entity_name.pascalCase()}}Repository] in the data layer. All methods
/// return [Result] so that callers handle failures through the type system
/// rather than catching exceptions.
library;

import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/entities/{{entity_name.snakeCase()}}.dart';

/// Contract for {{entity_name.camelCase()}} operations.
///
/// Implementations are responsible for communicating with the API,
/// and mapping data-layer models to domain entities.
abstract interface class I{{entity_name.pascalCase()}}Repository {
  /// Retrieve a single [{{entity_name.pascalCase()}}] by its [id].
  Future<Result<{{entity_name.pascalCase()}}>> getById(String id);

  /// Retrieve all available {{entity_name.camelCase()}} items.
  Future<Result<List<{{entity_name.pascalCase()}}>>> getAll();
}
