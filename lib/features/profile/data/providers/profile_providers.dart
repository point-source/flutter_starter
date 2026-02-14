/// Profile infrastructure providers.
///
/// Provides the [ProfileService] and [IProfileRepository] instances
/// used by the profile feature. Import this file (not the view model)
/// when you need access to profile infrastructure providers.
library;

import 'package:flutter_starter/core/network/dio_provider.dart';
import 'package:flutter_starter/features/profile/data/repositories/profile_repository.dart';
import 'package:flutter_starter/features/profile/data/services/profile_service.dart';
import 'package:flutter_starter/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_providers.g.dart';

/// Create a [ProfileService] backed by the application's [Dio] instance.
@riverpod
ProfileService profileService(Ref ref) => .new(ref.read(dioProvider));

/// Create an [IProfileRepository] wired to the profile service.
@riverpod
IProfileRepository profileRepository(Ref ref) =>
    ProfileRepository(ref.read(profileServiceProvider));
