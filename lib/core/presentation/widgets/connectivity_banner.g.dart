// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_banner.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectivityStatusHash() =>
    r'25b777118c00eda07ff9b630e052e7d15a0cc15c';

/// Stream the current connectivity status from [Connectivity].
///
/// Emits a new list of [ConnectivityResult] values whenever the
/// device's connectivity changes. An empty list or a list containing
/// only [ConnectivityResult.none] indicates no internet access.
///
/// Copied from [connectivityStatus].
@ProviderFor(connectivityStatus)
final connectivityStatusProvider =
    AutoDisposeStreamProvider<List<ConnectivityResult>>.internal(
      connectivityStatus,
      name: r'connectivityStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$connectivityStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityStatusRef =
    AutoDisposeStreamProviderRef<List<ConnectivityResult>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
