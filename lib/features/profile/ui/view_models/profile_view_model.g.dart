// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileServiceHash() => r'c71fe9ef088915b971249e44de2ffe32d9804191';

/// Create a [ProfileService] backed by the application's [Dio] instance.
///
/// Copied from [profileService].
@ProviderFor(profileService)
final profileServiceProvider = AutoDisposeProvider<ProfileService>.internal(
  profileService,
  name: r'profileServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileServiceRef = AutoDisposeProviderRef<ProfileService>;
String _$profileRepositoryHash() => r'4a25173557b96caebbf7096f4f0eb6c79c375892';

/// Create an [IProfileRepository] wired to the profile service.
///
/// Copied from [profileRepository].
@ProviderFor(profileRepository)
final profileRepositoryProvider =
    AutoDisposeProvider<IProfileRepository>.internal(
      profileRepository,
      name: r'profileRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileRepositoryRef = AutoDisposeProviderRef<IProfileRepository>;
String _$profileViewModelHash() => r'd40eab28e32b222c1908de627504de65069ce387';

/// Notifier that manages the profile lifecycle.
///
/// Loads the profile on initialization and provides an [updateProfile]
/// method for saving edits.
///
/// Copied from [ProfileViewModel].
@ProviderFor(ProfileViewModel)
final profileViewModelProvider =
    AutoDisposeAsyncNotifierProvider<ProfileViewModel, Profile>.internal(
      ProfileViewModel.new,
      name: r'profileViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProfileViewModel = AutoDisposeAsyncNotifier<Profile>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
