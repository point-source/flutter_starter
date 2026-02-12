/// Configure application routing with auto_route.
///
/// Defines the complete route tree including unauthenticated routes
/// (login, register) and authenticated routes (dashboard, profile,
/// settings) behind an [AuthGuard]. Authenticated routes are wrapped
/// in an [AutoTabsRoute] shell that provides adaptive navigation via
/// [AdaptiveScaffold].
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter/core/presentation/widgets/adaptive_scaffold.dart';
import 'package:flutter_starter/core/routing/guards/auth_guard.dart';
import 'package:flutter_starter/features/auth/ui/pages/login_page.dart';
import 'package:flutter_starter/features/auth/ui/pages/register_page.dart';
import 'package:flutter_starter/features/dashboard/ui/pages/dashboard_page.dart';
import 'package:flutter_starter/features/profile/ui/pages/profile_page.dart';
import 'package:flutter_starter/features/settings/ui/pages/settings_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';
part 'app_router.gr.dart';

/// Define the application route tree.
///
/// Uses [AutoRouterConfig] to generate route definitions from annotated
/// page widgets. The router accepts a [Ref] to create an [AuthGuard]
/// that protects authenticated routes.
///
/// Route structure:
/// - `/login` -- unauthenticated
/// - `/register` -- unauthenticated
/// - `/` (shell) -- authenticated, wraps tabbed navigation
///   - `/dashboard`
///   - `/profile`
///   - `/settings`
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  /// Create an [AppRouter] with the given Riverpod [ref].
  ///
  /// The [ref] is used to construct an [AuthGuard] that checks
  /// authentication state before allowing navigation to protected routes.
  AppRouter(this._ref);

  final Ref _ref;

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: RegisterRoute.page, path: '/register'),
    AutoRoute(
      page: ShellRoute.page,
      path: '/',
      guards: [AuthGuard(_ref)],
      children: [
        AutoRoute(page: DashboardRoute.page, path: 'dashboard'),
        AutoRoute(page: ProfileRoute.page, path: 'profile'),
        AutoRoute(page: SettingsRoute.page, path: 'settings'),
      ],
    ),
  ];

  @override
  RouteType get defaultRouteType => const .material();

  @override
  List<AutoRouteGuard> get guards => [];
}

/// Provide a single [AppRouter] instance scoped to the app's lifetime.
///
/// The router is created with a [Ref] so that [AuthGuard] can read
/// authentication state from the Riverpod provider tree.
@Riverpod(keepAlive: true)
AppRouter appRouter(Ref ref) => .new(ref);

/// Shell route that wraps authenticated tabs with [AdaptiveScaffold].
///
/// This page hosts the [AutoTabsRouter] and delegates navigation
/// chrome (bottom bar, rail, drawer) to [AdaptiveScaffold].
@RoutePage()
class ShellPage extends StatelessWidget {
  /// Create the shell page.
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context) => AutoTabsRouter(
    builder: (context, child) => AdaptiveScaffold(child: child),
  );
}
