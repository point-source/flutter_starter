/// Map [Failure] instances to localized, user-facing messages.
///
/// Uses the slang-generated translations to produce strings appropriate
/// for display in snack bars, banners, and dialogs. Infrastructure
/// failures (network, server, cache) and feature-specific failures
/// (auth, profile) are mapped to their corresponding translation keys;
/// unknown failures fall back to a generic error string.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_starter/core/error/failures.dart';
import 'package:flutter_starter/features/auth/domain/failures/auth_failure.dart';
import 'package:flutter_starter/features/profile/domain/failures/profile_failure.dart';
import 'package:flutter_starter/gen/strings.g.dart';

/// Return a localized user-facing message for the given [failure].
///
/// Maps infrastructure failure types and feature-specific failure subtypes
/// to their corresponding translation keys.
///
/// ```dart
/// final message = mapFailureToMessage(context, failure);
/// AppSnackbar.showError(context, message);
/// ```
String mapFailureToMessage(BuildContext _, Failure failure) =>
    switch (failure) {
      // Infrastructure failures
      NoConnection() => t.core.error.noConnection,
      Timeout() => t.core.error.timeout,
      BadResponse() ||
      Unauthorized() ||
      Forbidden() ||
      NotFound() => t.core.error.serverError,

      // Auth failures
      InvalidCredentials() => t.auth.error.invalidCredentials,
      EmailAlreadyInUse() => t.auth.error.emailTaken,
      SessionExpired() => t.auth.error.sessionExpired,
      AuthServerError() => t.auth.error.serverError,

      // Profile failures
      ProfileNotFound() => t.profile.error.loadFailed,
      ProfileUpdateRejected() => t.profile.error.updateFailed,

      _ => t.core.error.unexpected,
    };
