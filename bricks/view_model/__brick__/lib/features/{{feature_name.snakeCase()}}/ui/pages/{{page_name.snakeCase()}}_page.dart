/// {{page_name.pascalCase()}} page for the {{feature_name.camelCase()}} feature.
///
/// Displays content managed by [{{page_name.pascalCase()}}ViewModel] and
/// handles loading and error states.
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/ui/view_models/{{page_name.snakeCase()}}_view_model.dart';

/// Page that displays {{page_name.camelCase()}} content.
///
/// Watches [{{page_name.camelCase()}}ViewModelProvider] to react to loading,
/// data, and error states declaratively.
@RoutePage()
class {{page_name.pascalCase()}}Page extends ConsumerWidget {
  /// Create a [{{page_name.pascalCase()}}Page].
  const {{page_name.pascalCase()}}Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch({{page_name.camelCase()}}ViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('{{page_name.titleCase()}}'),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error.toString(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate({{page_name.camelCase()}}ViewModelProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (_) {
          // TODO: Build the page content.
          return const Center(
            child: Text('{{page_name.pascalCase()}} page content'),
          );
        },
      ),
    );
  }
}
