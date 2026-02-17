/// {{feature_name.pascalCase()}} infrastructure providers.
///
/// Provides the [I{{feature_name.pascalCase()}}Repository] instance used by the
/// {{feature_name.camelCase()}} feature. Import this file (not the view model)
/// when you need access to {{feature_name.camelCase()}} infrastructure providers.
library;

{{#dio}}import 'package:flutter_starter/core/http/dio_provider.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/repositories/{{feature_name.snakeCase()}}_repository.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/services/{{feature_name.snakeCase()}}_service.dart';
{{/dio}}{{^dio}}import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/repositories/mock_{{feature_name.snakeCase()}}_repository.dart';
{{/dio}}import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/repositories/i_{{feature_name.snakeCase()}}_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '{{feature_name.snakeCase()}}_providers.g.dart';

{{#dio}}/// Create a [{{feature_name.pascalCase()}}Service] backed by the
/// application's [Dio] instance.
@riverpod
{{feature_name.pascalCase()}}Service {{feature_name.camelCase()}}Service(Ref ref) =>
    {{feature_name.pascalCase()}}Service(ref.read(dioProvider));

/// Create an [I{{feature_name.pascalCase()}}Repository] wired to the
/// {{feature_name.camelCase()}} service.
@riverpod
I{{feature_name.pascalCase()}}Repository {{feature_name.camelCase()}}Repository(Ref ref) =>
    {{feature_name.pascalCase()}}Repository(
      ref.read({{feature_name.camelCase()}}ServiceProvider),
    );
{{/dio}}{{^dio}}/// Provide the [I{{feature_name.pascalCase()}}Repository] implementation.
///
/// Returns [Mock{{feature_name.pascalCase()}}Repository] by default. To connect
/// a real backend, replace this with your own implementation:
///
/// ```dart
/// @riverpod
/// I{{feature_name.pascalCase()}}Repository {{feature_name.camelCase()}}Repository(Ref ref) =>
///     MyBackend{{feature_name.pascalCase()}}Repository(ref.read(myServiceProvider));
/// ```
@riverpod
I{{feature_name.pascalCase()}}Repository {{feature_name.camelCase()}}Repository(Ref ref) =>
    const Mock{{feature_name.pascalCase()}}Repository();
{{/dio}}
