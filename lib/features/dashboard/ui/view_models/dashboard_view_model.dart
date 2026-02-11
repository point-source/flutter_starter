/// Provide dashboard state derived from the current authentication session.
///
/// Reads the [AuthViewModel] to extract the authenticated user's profile
/// and exposes it as a simple string for the welcome greeting.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flutter_starter/features/auth/ui/view_models/auth_view_model.dart';

part 'dashboard_view_model.g.dart';

/// View model for the dashboard page.
///
/// Watches the auth state and derives a greeting name from the
/// authenticated user's profile. Returns `null` when no user is
/// signed in.
@riverpod
class DashboardViewModel extends _$DashboardViewModel {
  @override
  String? build() {
    final authAsync = ref.watch(authViewModelProvider);
    return authAsync.whenOrNull(
      data: (state) => state.user?.name,
    );
  }
}
