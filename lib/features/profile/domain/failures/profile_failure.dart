/// Failure types specific to the profile feature.
///
/// Extends the base [Failure] to provide profile-specific error
/// semantics for the UI layer to handle.
library;

import 'package:flutter_starter/core/error/failures.dart';

/// Base class for profile-related failures.
sealed class ProfileFailure extends Failure {
  /// Create a [ProfileFailure].
  const ProfileFailure(super.message, [super.stackTrace]);
}

/// The profile could not be found on the server.
final class ProfileNotFound extends ProfileFailure {
  /// Create a [ProfileNotFound] failure.
  const ProfileNotFound([StackTrace? stackTrace])
      : super('Profile not found', stackTrace);
}

/// The profile update was rejected by the server.
final class ProfileUpdateRejected extends ProfileFailure {
  /// Create a [ProfileUpdateRejected] failure.
  const ProfileUpdateRejected([String? message, StackTrace? stackTrace])
      : super(message ?? 'Profile update failed', stackTrace);
}
