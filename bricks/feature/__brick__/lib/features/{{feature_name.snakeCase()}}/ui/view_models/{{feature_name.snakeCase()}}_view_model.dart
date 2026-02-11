/// Manage {{feature_name.camelCase()}} state and expose operations to the UI.
///
/// Provides the [{{feature_name.pascalCase()}}ViewModel] notifier and
/// companion providers:
/// - [{{feature_name.camelCase()}}ServiceProvider] -- the retrofit
///   [{{feature_name.pascalCase()}}Service]
/// - [{{feature_name.camelCase()}}RepositoryProvider] -- the
///   [I{{feature_name.pascalCase()}}Repository] implementation
///
/// The view model wraps [I{{feature_name.pascalCase()}}Repository] calls in
/// [AsyncValue] so that the UI can react to loading, data, and error
/// states declaratively.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flutter_starter/core/network/dio_provider.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/repositories/{{feature_name.snakeCase()}}_repository.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/services/{{feature_name.snakeCase()}}_service.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/repositories/i_{{feature_name.snakeCase()}}_repository.dart';

part '{{feature_name.snakeCase()}}_view_model.g.dart';

// ---------------------------------------------------------------------------
// Infrastructure providers
// ---------------------------------------------------------------------------

/// Create a [{{feature_name.pascalCase()}}Service] backed by the
/// application's [Dio] instance.
@riverpod
{{feature_name.pascalCase()}}Service {{feature_name.camelCase()}}Service(Ref ref) {
  return {{feature_name.pascalCase()}}Service(ref.read(dioProvider));
}

/// Create an [I{{feature_name.pascalCase()}}Repository] wired to the
/// {{feature_name.camelCase()}} service.
@riverpod
I{{feature_name.pascalCase()}}Repository {{feature_name.camelCase()}}Repository(Ref ref) {
  return {{feature_name.pascalCase()}}Repository(
    ref.read({{feature_name.camelCase()}}ServiceProvider),
  );
}

// ---------------------------------------------------------------------------
// View model
// ---------------------------------------------------------------------------

/// Notifier that manages the {{feature_name.camelCase()}} lifecycle.
///
/// The [build] method loads the initial data. Add methods for create,
/// update, and delete operations as needed.
@riverpod
class {{feature_name.pascalCase()}}ViewModel extends _${{feature_name.pascalCase()}}ViewModel {
  @override
  Future<List<{{feature_name.pascalCase()}}>> build() async {
    final repository = ref.read({{feature_name.camelCase()}}RepositoryProvider);
    final result = await repository.getAll();

    return result.when(
      success: (items) => items,
      failure: (failure) => throw failure,
    );
  }
}
