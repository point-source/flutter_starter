// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Create a [ProfileService] backed by the application's [Dio] instance.

@ProviderFor(profileService)
final profileServiceProvider = ProfileServiceProvider._();

/// Create a [ProfileService] backed by the application's [Dio] instance.

final class ProfileServiceProvider
    extends $FunctionalProvider<ProfileService, ProfileService, ProfileService>
    with $Provider<ProfileService> {
  /// Create a [ProfileService] backed by the application's [Dio] instance.
  ProfileServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileServiceHash();

  @$internal
  @override
  $ProviderElement<ProfileService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProfileService create(Ref ref) {
    return profileService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileService>(value),
    );
  }
}

String _$profileServiceHash() => r'c71fe9ef088915b971249e44de2ffe32d9804191';

/// Create an [IProfileRepository] wired to the profile service.

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

/// Create an [IProfileRepository] wired to the profile service.

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          IProfileRepository,
          IProfileRepository,
          IProfileRepository
        >
    with $Provider<IProfileRepository> {
  /// Create an [IProfileRepository] wired to the profile service.
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<IProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'4a25173557b96caebbf7096f4f0eb6c79c375892';

/// Notifier that manages the profile lifecycle.
///
/// Loads the profile on initialization and provides an [updateProfile]
/// method for saving edits.

@ProviderFor(ProfileViewModel)
final profileViewModelProvider = ProfileViewModelProvider._();

/// Notifier that manages the profile lifecycle.
///
/// Loads the profile on initialization and provides an [updateProfile]
/// method for saving edits.
final class ProfileViewModelProvider
    extends $AsyncNotifierProvider<ProfileViewModel, Profile> {
  /// Notifier that manages the profile lifecycle.
  ///
  /// Loads the profile on initialization and provides an [updateProfile]
  /// method for saving edits.
  ProfileViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileViewModelHash();

  @$internal
  @override
  ProfileViewModel create() => ProfileViewModel();
}

String _$profileViewModelHash() => r'd40eab28e32b222c1908de627504de65069ce387';

/// Notifier that manages the profile lifecycle.
///
/// Loads the profile on initialization and provides an [updateProfile]
/// method for saving edits.

abstract class _$ProfileViewModel extends $AsyncNotifier<Profile> {
  FutureOr<Profile> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Profile>, Profile>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Profile>, Profile>,
              AsyncValue<Profile>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
