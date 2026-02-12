/// Tests for [{{feature_name.pascalCase()}}ViewModel].
///
/// Uses a [ProviderContainer] with a mocked [I{{feature_name.pascalCase()}}Repository]
/// to verify that the view model correctly translates repository results into
/// [AsyncValue] transitions.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/error/failures.dart';
import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/failures/{{feature_name.snakeCase()}}_failure.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/ui/view_models/{{feature_name.snakeCase()}}_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_utils.dart';

void main() {
  late Mock{{feature_name.pascalCase()}}Repository mockRepository;

  setUp(() {
    mockRepository = Mock{{feature_name.pascalCase()}}Repository();
  });

  /// Helper to create a container with the repository overridden.
  ProviderContainer create{{feature_name.pascalCase()}}Container() => createContainer(
    overrides: [
      {{feature_name.camelCase()}}RepositoryProvider.overrideWithValue(mockRepository),
    ],
  );

  /// Tests for the initial [build] method.
  group('build', () {
    /// Resolves to a list of entities on success.
    test('returns data on success', () async {
      const testEntity = {{feature_name.pascalCase()}}(id: 'test-1');

      when(
        () => mockRepository.getAll(),
      ).thenAnswer((_) async => const Success([testEntity]));

      final container = create{{feature_name.pascalCase()}}Container();

      final items = await container.read(
        {{feature_name.camelCase()}}ViewModelProvider.future,
      );

      expect(items, hasLength(1));
      expect(items.first.id, 'test-1');
    });

    /// Transitions to error state when repository returns a failure.
    test('throws on failure', () async {
      when(
        () => mockRepository.getAll(),
      ).thenAnswer(
        (_) async => const Err({{feature_name.pascalCase()}}ServerError()),
      );

      final container = create{{feature_name.pascalCase()}}Container();

      final state = await container.read(
        {{feature_name.camelCase()}}ViewModelProvider.future,
      ).then((_) => null).catchError((Object e) => e);

      expect(state, isA<{{feature_name.pascalCase()}}Failure>());
    });
  });
}
