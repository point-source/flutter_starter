// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provide the [IProfileRepository] implementation.
///
/// Returns [MockProfileRepository] when `BACKEND=mock` (the default).
/// When `BACKEND=real`, replace the [UnimplementedError] with your own
/// [IProfileRepository] backed by Supabase, Firebase, Dio, etc.

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

/// Provide the [IProfileRepository] implementation.
///
/// Returns [MockProfileRepository] when `BACKEND=mock` (the default).
/// When `BACKEND=real`, replace the [UnimplementedError] with your own
/// [IProfileRepository] backed by Supabase, Firebase, Dio, etc.

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
  /// Returns [MockProfileRepository] when `BACKEND=mock` (the default).
  /// When `BACKEND=real`, replace the [UnimplementedError] with your own
  /// [IProfileRepository] backed by Supabase, Firebase, Dio, etc.
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

String _$profileRepositoryHash() => r'40cb7188f8c9c4f26f1f63760714425f02ca5cd5';
