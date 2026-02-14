# Architecture Rule 04: Navigation Rules

## Overview

All navigation uses **auto_route** with code-generated route definitions. Routes are defined in `AppRouter`, pages are annotated with `@RoutePage()`, and authentication is enforced via `AuthGuard`.

## Route Definition

All routes are declared in `lib/core/routing/app_router.dart`:

```dart
@AutoRouterConfig(replaceInRouteName: 'Page|Screen,Route')
class AppRouter extends RootStackRouter {
  AppRouter(this._ref);
  final Ref _ref;

  @override
  List<AutoRoute> get routes => [
    // Unauthenticated routes
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: RegisterRoute.page, path: '/register'),

    // Authenticated shell (tabbed navigation)
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
}
```

## Page Annotation

Every page widget must be annotated with `@RoutePage()`:

```dart
@RoutePage()
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ...
  }
}
```

The `replaceInRouteName: 'Page|Screen,Route'` config means `LoginPage` generates `LoginRoute`.

## Route Guards

### AuthGuard

The `AuthGuard` protects authenticated routes by checking `isAuthenticatedProvider`:

```dart
class AuthGuard extends AutoRouteGuard {
  AuthGuard(this._ref);
  final Ref _ref;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (isAuthenticated) {
      resolver.next();
    } else {
      resolver.next(false);
      router.replaceAll(const [LoginRoute()]);
    }
  }
}
```

### Riverpod Integration

The `AppRouter` is created inside a `@Riverpod(keepAlive: true)` provider so that `Ref` can be passed to guards:

```dart
@Riverpod(keepAlive: true)
AppRouter appRouter(Ref ref) => AppRouter(ref);
```

## Shell Route (Tabbed Navigation)

The `ShellPage` wraps authenticated tabs with `AdaptiveScaffold`, which renders different navigation chrome based on screen width:

- Compact (< 600dp): Bottom navigation bar
- Medium (600-840dp): Navigation rail
- Expanded (840-1200dp): Navigation rail with labels
- Large (1200dp+): Persistent navigation drawer

## Navigation in Code

```dart
// Push a route
context.router.push(const ProfileRoute());

// Replace current route
context.router.replace(const DashboardRoute());

// Pop current route
context.router.maybePop();

// Navigate to a specific tab (inside shell)
context.tabsRouter.setActiveIndex(1);
```

## Adding a New Route

1. Create the page widget with `@RoutePage()` annotation.
2. Add an `AutoRoute` entry in `AppRouter.routes`.
3. Run `dart run build_runner build` to regenerate `app_router.gr.dart`.
4. If the route needs authentication, place it inside the shell route's `children` or add `guards: [AuthGuard(_ref)]`.

## DO

- Define all routes in `AppRouter.routes` -- no programmatic route registration elsewhere.
- Use `@RoutePage()` on every page widget.
- Apply `AuthGuard` to all routes that require authentication.
- Use type-safe navigation (`context.router.push(const MyRoute())`) instead of string paths.
- Pass route parameters through the route constructor, not through global state.

## DO NOT

- Do not use `Navigator.push` or `Navigator.of(context)` -- use auto_route's `context.router`.
- Do not create multiple `AppRouter` instances -- use the `appRouterProvider`.
- Do not read auth state with `ref.watch` inside `AuthGuard` -- use `ref.read` since guards run synchronously during navigation.
- Do not put business logic in route guards -- guards should only check permissions and redirect.
- Do not define routes outside of `app_router.dart`.
