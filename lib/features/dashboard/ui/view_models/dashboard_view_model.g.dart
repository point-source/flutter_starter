// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// View model for the dashboard page.
///
/// Watches the auth state and derives a greeting name from the
/// authenticated user's profile. Returns `null` when no user is
/// signed in.

@ProviderFor(DashboardViewModel)
final dashboardViewModelProvider = DashboardViewModelProvider._();

/// View model for the dashboard page.
///
/// Watches the auth state and derives a greeting name from the
/// authenticated user's profile. Returns `null` when no user is
/// signed in.
final class DashboardViewModelProvider
    extends $NotifierProvider<DashboardViewModel, String?> {
  /// View model for the dashboard page.
  ///
  /// Watches the auth state and derives a greeting name from the
  /// authenticated user's profile. Returns `null` when no user is
  /// signed in.
  DashboardViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardViewModelHash();

  @$internal
  @override
  DashboardViewModel create() => DashboardViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$dashboardViewModelHash() =>
    r'5894f059c8487beacf8a9f413e68716e331e64b6';

/// View model for the dashboard page.
///
/// Watches the auth state and derives a greeting name from the
/// authenticated user's profile. Returns `null` when no user is
/// signed in.

abstract class _$DashboardViewModel extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
