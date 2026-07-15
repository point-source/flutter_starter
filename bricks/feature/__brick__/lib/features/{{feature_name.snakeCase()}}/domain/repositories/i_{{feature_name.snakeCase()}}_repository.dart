/// Define the contract for {{feature_name.camelCase()}} operations.
///
/// This interface sits in the domain layer and is implemented by
/// [{{feature_name.pascalCase()}}Repository] in the data layer. All methods
/// return [Result] so that callers handle failures through the type system
/// rather than catching exceptions.
library;

import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}.dart';

/// Contract for {{feature_name.camelCase()}} operations.
///
/// Implementations communicate with the selected data source and map any
/// source-specific models or errors to domain entities and [Result] failures.
abstract interface class I{{feature_name.pascalCase()}}Repository {
  /// Retrieve a single [{{feature_name.pascalCase()}}] by its [id].
  Future<Result<{{feature_name.pascalCase()}}>> getById(String id);

  /// Retrieve all available {{feature_name.camelCase()}} items.
  Future<Result<List<{{feature_name.pascalCase()}}>>> getAll();
}
