// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provide a single [AppRouter] instance scoped to the app's lifetime.
///
/// The router is created with a [Ref] so that [AuthGuard] can read
/// authentication state from the Riverpod provider tree.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// Provide a single [AppRouter] instance scoped to the app's lifetime.
///
/// The router is created with a [Ref] so that [AuthGuard] can read
/// authentication state from the Riverpod provider tree.

final class AppRouterProvider
    extends $FunctionalProvider<AppRouter, AppRouter, AppRouter>
    with $Provider<AppRouter> {
  /// Provide a single [AppRouter] instance scoped to the app's lifetime.
  ///
  /// The router is created with a [Ref] so that [AuthGuard] can read
  /// authentication state from the Riverpod provider tree.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<AppRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppRouter>(value),
    );
  }
}

String _$appRouterHash() => r'9d92c322cab6fc203093cf11e29f1e032b876613';
