/// Manage state for the {{page_name.pascalCase()}} page.
///
/// Provides the [{{page_name.pascalCase()}}ViewModel] notifier that the
/// [{{page_name.pascalCase()}}Page] watches to react to loading, data, and
/// error states declaratively.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '{{page_name.snakeCase()}}_view_model.g.dart';

// ---------------------------------------------------------------------------
// View model
// ---------------------------------------------------------------------------

/// Notifier that manages the {{page_name.camelCase()}} page state.
///
/// The [build] method loads the initial data. Add methods for user
/// interactions as needed.
@riverpod
class {{page_name.pascalCase()}}ViewModel extends _${{page_name.pascalCase()}}ViewModel {
  @override
  Future<void> build() async {
    // TODO: Load initial data from repository.
  }
}
