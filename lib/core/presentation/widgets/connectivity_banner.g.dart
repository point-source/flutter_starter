// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_banner.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stream the current connectivity status from [Connectivity].
///
/// Emits a new list of [ConnectivityResult] values whenever the
/// device's connectivity changes. An empty list or a list containing
/// only [ConnectivityResult.none] indicates no internet access.

@ProviderFor(connectivityStatus)
final connectivityStatusProvider = ConnectivityStatusProvider._();

/// Stream the current connectivity status from [Connectivity].
///
/// Emits a new list of [ConnectivityResult] values whenever the
/// device's connectivity changes. An empty list or a list containing
/// only [ConnectivityResult.none] indicates no internet access.

final class ConnectivityStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConnectivityResult>>,
          List<ConnectivityResult>,
          Stream<List<ConnectivityResult>>
        >
    with
        $FutureModifier<List<ConnectivityResult>>,
        $StreamProvider<List<ConnectivityResult>> {
  /// Stream the current connectivity status from [Connectivity].
  ///
  /// Emits a new list of [ConnectivityResult] values whenever the
  /// device's connectivity changes. An empty list or a list containing
  /// only [ConnectivityResult.none] indicates no internet access.
  ConnectivityStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityStatusHash();

  @$internal
  @override
  $StreamProviderElement<List<ConnectivityResult>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ConnectivityResult>> create(Ref ref) {
    return connectivityStatus(ref);
  }
}

String _$connectivityStatusHash() =>
    r'e1e7edb0399a32a7bdcb4413ee6b3e5b3854a651';
