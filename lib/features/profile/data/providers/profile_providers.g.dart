// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

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

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          IProfileRepository,
          IProfileRepository,
          IProfileRepository
        >
    with $Provider<IProfileRepository> {
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

String _$profileRepositoryHash() => r'1c984d019fbca26b4fcbb9815bd6920b8b552b1a';
