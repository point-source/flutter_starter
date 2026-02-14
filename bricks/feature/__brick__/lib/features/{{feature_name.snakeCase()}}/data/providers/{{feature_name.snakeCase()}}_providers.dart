/// {{feature_name.pascalCase()}} infrastructure providers.
///
/// Provides the [{{feature_name.pascalCase()}}Service] and
/// [I{{feature_name.pascalCase()}}Repository] instances used by the
/// {{feature_name.camelCase()}} feature. Import this file (not the view model)
/// when you need access to {{feature_name.camelCase()}} infrastructure providers.
library;

import 'package:flutter_starter/core/network/dio_provider.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/repositories/{{feature_name.snakeCase()}}_repository.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/services/{{feature_name.snakeCase()}}_service.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/repositories/i_{{feature_name.snakeCase()}}_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '{{feature_name.snakeCase()}}_providers.g.dart';

/// Create a [{{feature_name.pascalCase()}}Service] backed by the
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
