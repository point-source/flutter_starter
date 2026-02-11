/// Main page for the {{feature_name.camelCase()}} feature.
///
/// Displays a list of {{feature_name.camelCase()}} items and handles loading
/// and error states. Uses [{{feature_name.pascalCase()}}ViewModel] to fetch
/// and manage the data.
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/ui/view_models/{{feature_name.snakeCase()}}_view_model.dart';

/// Page that displays {{feature_name.camelCase()}} data.
///
/// Watches [{{feature_name.camelCase()}}ViewModelProvider] to react to loading,
/// data, and error states declaratively.
@RoutePage()
class {{feature_name.pascalCase()}}Page extends ConsumerWidget {
  /// Create a [{{feature_name.pascalCase()}}Page].
  const {{feature_name.pascalCase()}}Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch({{feature_name.camelCase()}}ViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('{{feature_name.titleCase()}}'),
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
                onPressed: () => ref.invalidate({{feature_name.camelCase()}}ViewModelProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('No items found.'),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.id),
              );
            },
          );
        },
      ),
    );
  }
}
