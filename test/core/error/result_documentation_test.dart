/// Compile and exercise the repository example documented by [Result].
library;

import 'package:flutter_starter/core/error/failures.dart';
import 'package:flutter_starter/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

abstract interface class _PreferenceSource {
  Future<String> readTheme();
}

final class _SourceReadException implements Exception {
  const _SourceReadException();
}

final class _PreferenceReadFailure extends Failure {
  const _PreferenceReadFailure([StackTrace? stackTrace])
    : super('Could not read the theme preference', stackTrace);
}

final class _StubPreferenceSource implements _PreferenceSource {
  _StubPreferenceSource(this._read);

  final Future<String> Function() _read;

  @override
  Future<String> readTheme() => _read();
}

final class _PreferenceRepository {
  const _PreferenceRepository(this._source);

  final _PreferenceSource _source;

  Future<Result<String>> loadTheme() async {
    try {
      return Success(await _source.readTheme());
    } on _SourceReadException catch (_, stackTrace) {
      return Err(_PreferenceReadFailure(stackTrace));
    } on Exception catch (error, stackTrace) {
      return Err(UnexpectedFailure(error, stackTrace));
    }
  }
}

void main() {
  group('documented repository Result contract', () {
    test('returns source data as Success', () async {
      final repository = _PreferenceRepository(
        _StubPreferenceSource(() async => 'dark'),
      );

      final result = await repository.loadTheme();

      expect(result, const Success('dark'));
    });

    test('maps a source exception to an application Failure', () async {
      final repository = _PreferenceRepository(
        _StubPreferenceSource(() async => throw const _SourceReadException()),
      );

      final result = await repository.loadTheme();

      expect(result, isA<Err<String>>());
      expect(result.failureOrNull, isA<_PreferenceReadFailure>());
    });

    test('preserves an unexpected error and stack trace', () async {
      final error = Exception('unexpected');
      final repository = _PreferenceRepository(
        _StubPreferenceSource(() async => throw error),
      );

      final result = await repository.loadTheme();

      final failure = result.failureOrNull! as UnexpectedFailure;
      expect(failure.error, same(error));
      expect(failure.stackTrace, isNotNull);
    });
  });
}
