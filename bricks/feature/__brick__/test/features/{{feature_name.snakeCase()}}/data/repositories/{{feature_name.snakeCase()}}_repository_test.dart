{{#dio}}/// Verify the REST repository preserves the public Result contract.
library;

import 'package:dio/dio.dart';
import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_starter/core/http/dio_api_exception.dart';
import 'package:flutter_starter/core/logging/app_logger.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/models/{{feature_name.snakeCase()}}_dto.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/repositories/{{feature_name.snakeCase()}}_repository.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/data/services/{{feature_name.snakeCase()}}_service.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}.dart';
import 'package:flutter_starter/features/{{feature_name.snakeCase()}}/domain/failures/{{feature_name.snakeCase()}}_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Mock{{feature_name.pascalCase()}}Service extends Mock
    implements {{feature_name.pascalCase()}}Service {}

class _MockLogger extends Mock implements IAppLogger {}

void main() {
  late _Mock{{feature_name.pascalCase()}}Service service;
  late {{feature_name.pascalCase()}}Repository repository;

  setUp(() {
    service = _Mock{{feature_name.pascalCase()}}Service();
    repository = {{feature_name.pascalCase()}}Repository(service, _MockLogger());
  });

  test('maps a REST response to Success', () async {
    when(service.getAll).thenAnswer(
      (_) async => [const {{feature_name.pascalCase()}}Dto(id: 'rest-1')],
    );

    final result = await repository.getAll();

    expect(result, isA<Success<List<{{feature_name.pascalCase()}}>>>());
    expect(result.getOrNull()?.single.id, 'rest-1');
  });

  test('maps a transport exception to an Err feature failure', () async {
    when(service.getAll).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/{{feature_name.paramCase()}}'),
        type: DioExceptionType.badResponse,
        error: const ServerException('Unavailable', statusCode: 503),
      ),
    );

    final result = await repository.getAll();

    expect(result, isA<Err<List<{{feature_name.pascalCase()}}>>>());
    final failure = result.when(
      success: (_) => null,
      failure: (failure) => failure,
    );
    expect(failure, isA<{{feature_name.pascalCase()}}ServerError>());
    expect(failure?.message, '{{feature_name.pascalCase()}} service unavailable');
    expect(failure?.message, isNot(contains('Unavailable')));
  });
}
{{/dio}}
