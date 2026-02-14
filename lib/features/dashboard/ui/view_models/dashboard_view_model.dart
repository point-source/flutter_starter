/// Provide dashboard state derived from the current authentication session.
///
/// Reads [authStateRepoProvider] to extract the authenticated user's profile
/// and exposes it as a simple string for the welcome greeting.
library;

import 'package:flutter_starter/features/auth/data/providers/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    final authAsync = ref.watch(authStateRepoProvider);
    return authAsync.whenOrNull(data: (state) => state.user?.name);
  }
}
