// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardViewModelHash() =>
    r'5894f059c8487beacf8a9f413e68716e331e64b6';

/// View model for the dashboard page.
///
/// Watches the auth state and derives a greeting name from the
/// authenticated user's profile. Returns `null` when no user is
/// signed in.
///
/// Copied from [DashboardViewModel].
@ProviderFor(DashboardViewModel)
final dashboardViewModelProvider =
    AutoDisposeNotifierProvider<DashboardViewModel, String?>.internal(
      DashboardViewModel.new,
      name: r'dashboardViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DashboardViewModel = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
