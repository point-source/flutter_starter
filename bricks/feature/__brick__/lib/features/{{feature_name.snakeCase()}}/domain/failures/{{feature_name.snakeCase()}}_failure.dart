/// {{feature_name.pascalCase()}}-specific failure types.
///
/// These failures are returned by [I{{feature_name.pascalCase()}}Repository]
/// methods when a {{feature_name.camelCase()}} operation fails. Each subtype
/// maps to a specific error condition so that the UI layer can display
/// targeted messages or take appropriate recovery actions.
library;

import 'package:flutter_starter/core/error/failures.dart';

/// Base class for all {{feature_name.camelCase()}} failures.
///
/// Extend this class to add new {{feature_name.camelCase()}}-specific failure
/// cases. The sealed hierarchy ensures exhaustive pattern matching in the
/// UI layer.
sealed class {{feature_name.pascalCase()}}Failure extends Failure {
  /// Create a [{{feature_name.pascalCase()}}Failure] with a [message] and
  /// optional [stackTrace].
  const {{feature_name.pascalCase()}}Failure(super.message, [super.stackTrace]);
}

/// The requested {{feature_name.camelCase()}} was not found.
final class {{feature_name.pascalCase()}}NotFound extends {{feature_name.pascalCase()}}Failure {
  /// Create a [{{feature_name.pascalCase()}}NotFound] failure.
  const {{feature_name.pascalCase()}}NotFound([StackTrace? stackTrace])
      : super('{{feature_name.pascalCase()}} not found', stackTrace);
}

/// An unexpected server-side error occurred.
final class {{feature_name.pascalCase()}}ServerError extends {{feature_name.pascalCase()}}Failure {
  /// Create a [{{feature_name.pascalCase()}}ServerError] failure with an
  /// optional detail [message].
  const {{feature_name.pascalCase()}}ServerError([
    String message = '{{feature_name.pascalCase()}} server error',
    StackTrace? stackTrace,
  ]) : super(message, stackTrace);
}
