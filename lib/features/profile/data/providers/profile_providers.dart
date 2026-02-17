/// Profile infrastructure providers.
///
/// Provides the [IProfileRepository] instance used by the profile feature.
/// Import this file (not the view model) when you need access to profile
/// infrastructure providers.
library;

import 'package:flutter_starter/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:flutter_starter/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_providers.g.dart';

/// Provide the [IProfileRepository] implementation.
///
/// Returns [MockProfileRepository] by default. To connect a real backend,
/// replace this with your own implementation of [IProfileRepository]:
///
/// ```dart
/// @riverpod
/// IProfileRepository profileRepository(Ref ref) =>
///     MyBackendProfileRepository(ref.read(myServiceProvider));
/// ```
@riverpod
IProfileRepository profileRepository(Ref ref) => const MockProfileRepository();
