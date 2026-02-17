/// Fake [I{{feature_name.pascalCase()}}Repository] for development without a backend.
///
/// Returns hard-coded data for all operations, with no network calls.
/// Replace with a real implementation when connecting to a backend.
library;

import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/repositories/i_{{feature_name.snakeCase()}}_repository.dart';

/// [I{{feature_name.pascalCase()}}Repository] implementation that returns
/// fake data immediately.
///
/// Useful for UI development when no backend is available.
class Mock{{feature_name.pascalCase()}}Repository implements I{{feature_name.pascalCase()}}Repository {
  /// Create a [Mock{{feature_name.pascalCase()}}Repository].
  const Mock{{feature_name.pascalCase()}}Repository();

  static const _mock = {{feature_name.pascalCase()}}(id: 'mock-1');

  @override
  Future<Result<{{feature_name.pascalCase()}}>> getById(String id) async =>
      Success({{feature_name.pascalCase()}}(id: id));

  @override
  Future<Result<List<{{feature_name.pascalCase()}}>>> getAll() async =>
      const Success([_mock]);
}
