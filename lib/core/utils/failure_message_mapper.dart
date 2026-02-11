/// Map [Failure] instances to localized, user-facing messages.
///
/// Uses the slang-generated translations to produce strings appropriate
/// for display in snack bars, banners, and dialogs. Infrastructure
/// failures (network, server, cache) are mapped to predefined messages;
/// unknown failures fall back to a generic error string.
library;

import 'package:flutter/widgets.dart';

import 'package:flutter_starter/core/error/failures.dart';
import 'package:flutter_starter/gen/strings.g.dart';

/// Return a localized user-facing message for the given [failure].
///
/// Maps infrastructure failure types to their corresponding translation
/// keys. Feature-specific failures should be handled by their own
/// mappers or by extending this function.
///
/// ```dart
/// final message = mapFailureToMessage(context, failure);
/// AppSnackbar.showError(context, message);
/// ```
String mapFailureToMessage(BuildContext context, Failure failure) {
  return switch (failure) {
    NoConnection() => t.core.error.noConnection,
    Timeout() => t.core.error.timeout,
    BadResponse() => t.core.error.serverError,
    Unauthorized() => t.core.error.serverError,
    Forbidden() => t.core.error.serverError,
    NotFound() => t.core.error.serverError,
    CacheReadFailure() => t.core.error.unexpected,
    CacheWriteFailure() => t.core.error.unexpected,
    UnexpectedFailure() => t.core.error.unexpected,
    _ => t.core.error.unexpected,
  };
}
