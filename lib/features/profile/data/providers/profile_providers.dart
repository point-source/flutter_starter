/// Profile infrastructure providers.
///
/// Provides the [IProfileRepository] instance used by the profile feature.
/// Import this file (not the view model) when you need access to profile
/// infrastructure providers.
library;

import 'package:flutter_starter/core/env/app_environment.dart';
import 'package:flutter_starter/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:flutter_starter/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_providers.g.dart';

/// Provide the [IProfileRepository] implementation.
///
/// Returns [MockProfileRepository] when `BACKEND=mock` (the default).
/// When `BACKEND=real`, replace the [UnimplementedError] with your own
/// [IProfileRepository] backed by Supabase, Firebase, Dio, etc.
@riverpod
IProfileRepository profileRepository(Ref ref) {
  if (AppEnvironment.backendMode == BackendMode.mock) {
    return const MockProfileRepository();
  }
  // TODO: Replace with your backend implementation.
  throw UnimplementedError(
    'BACKEND is set to "real" but no profile backend is configured. '
    'Implement IProfileRepository and return it here.',
  );
}
