/// Manage {{feature_name.camelCase()}} state and expose operations to the UI.
///
/// Provides the [{{feature_name.pascalCase()}}ViewModel] notifier that the
/// {{feature_name.camelCase()}} page watches to react to loading, data, and
/// error states.
///
/// Infrastructure providers ([{{feature_name.camelCase()}}ServiceProvider],
/// [{{feature_name.camelCase()}}RepositoryProvider]) live in
/// `data/providers/{{feature_name.snakeCase()}}_providers.dart`.
///
/// **Note:** View models are optional. Only create one when the page needs
/// significant data transformation between the domain and the UI. If the
/// page would just pass through data from a provider, watch that provider
/// directly instead.
library;

import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/providers/{{feature_name.snakeCase()}}_providers.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '{{feature_name.snakeCase()}}_view_model.g.dart';

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
