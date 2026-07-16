{{#dio}}/// Exercise visible REST feature success and failure states.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/providers/{{feature_name.snakeCase()}}_providers.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/failures/{{feature_name.snakeCase()}}_failure.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/repositories/i_{{feature_name.snakeCase()}}_repository.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/ui/pages/{{feature_name.snakeCase()}}_page.dart';
import 'package:flutter_test/flutter_test.dart';

class _ResultRepository implements I{{feature_name.pascalCase()}}Repository {
  const _ResultRepository(this.result);

  final Result<List<{{feature_name.pascalCase()}}>> result;

  @override
  Future<Result<List<{{feature_name.pascalCase()}}>>> getAll() async => result;

  @override
  Future<Result<{{feature_name.pascalCase()}}>> getById(String id) async =>
      result.when(
        success: (items) => Success(items.first),
        failure: Err.new,
      );
}

Widget _app(Result<List<{{feature_name.pascalCase()}}>> result) => ProviderScope(
      overrides: [
        {{feature_name.camelCase()}}RepositoryProvider.overrideWith(
          (ref) => _ResultRepository(result),
        ),
      ],
      child: const MaterialApp(home: {{feature_name.pascalCase()}}Page()),
    );

void main() {
  testWidgets('renders REST success data', (tester) async {
    await tester.pumpWidget(
      _app(const Success([{{feature_name.pascalCase()}}(id: 'rest-1')])),
    );
    await tester.pumpAndSettle();

    expect(find.text('rest-1'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('renders Result failure and retry action', (tester) async {
    await tester.pumpWidget(
      _app(
        const Err(
          {{feature_name.pascalCase()}}ServerError('Service unavailable'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Service unavailable'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
{{/dio}}
