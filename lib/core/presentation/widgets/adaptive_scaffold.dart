/// Provide an adaptive navigation shell that switches between navigation
/// patterns based on viewport width.
///
/// Uses [ResponsiveBuilder] to display a [BottomNavigationBar] on phones,
/// a [NavigationRail] on tablets, and a persistent [NavigationDrawer] on
/// large screens. Tab navigation is driven by [AutoTabsRouter].
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_starter/core/presentation/responsive/responsive_builder.dart';
import 'package:flutter_starter/gen/strings.g.dart';

/// Adaptive navigation scaffold for authenticated routes.
///
/// Wraps the current tab [child] in the appropriate navigation chrome
/// based on the current [AppBreakpoint]:
///
/// | Breakpoint | Navigation              |
/// |------------|-------------------------|
/// | compact    | [BottomNavigationBar]    |
/// | medium     | [NavigationRail]         |
/// | expanded   | [NavigationRail] (ext.)  |
/// | large      | [NavigationDrawer]       |
///
/// Navigation items (Dashboard, Profile, Settings) map 1:1 to the tab
/// indices managed by [AutoTabsRouter].
class AdaptiveScaffold extends ConsumerWidget {
  /// Create an [AdaptiveScaffold] that wraps the given [child].
  const AdaptiveScaffold({required this.child, super.key});

  /// The routed page content displayed alongside the navigation chrome.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsRouter = AutoTabsRouter.of(context);
    final activeIndex = tabsRouter.activeIndex;

    return ResponsiveBuilder(
      compactBuilder: (context) =>
          _buildCompact(context, tabsRouter, activeIndex),
      mediumBuilder: (context) =>
          _buildMedium(context, tabsRouter, activeIndex),
      expandedBuilder: (context) =>
          _buildExpanded(context, tabsRouter, activeIndex),
      largeBuilder: (context) => _buildLarge(context, tabsRouter, activeIndex),
    );
  }

  /// Build a compact layout with a [BottomNavigationBar].
  Widget _buildCompact(
    BuildContext _,
    TabsRouter tabsRouter,
    int activeIndex,
  ) => Scaffold(
    body: child,
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: activeIndex,
      onTap: tabsRouter.setActiveIndex,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard),
          label: t.core.nav.dashboard,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: t.core.nav.profile,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: t.core.nav.settings,
        ),
      ],
    ),
  );

  /// Build a medium layout with a collapsed [NavigationRail].
  Widget _buildMedium(BuildContext _, TabsRouter tabsRouter, int activeIndex) =>
      Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: activeIndex,
              onDestinationSelected: tabsRouter.setActiveIndex,
              labelType: .selected,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.dashboard_outlined),
                  selectedIcon: const Icon(Icons.dashboard),
                  label: Text(t.core.nav.dashboard),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.person_outlined),
                  selectedIcon: const Icon(Icons.person),
                  label: Text(t.core.nav.profile),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: Text(t.core.nav.settings),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );

  /// Build an expanded layout with an extended [NavigationRail].
  Widget _buildExpanded(
    BuildContext _,
    TabsRouter tabsRouter,
    int activeIndex,
  ) => Scaffold(
    body: Row(
      children: [
        NavigationRail(
          selectedIndex: activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
          extended: true,
          destinations: [
            NavigationRailDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard),
              label: Text(t.core.nav.dashboard),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.person_outlined),
              selectedIcon: const Icon(Icons.person),
              label: Text(t.core.nav.profile),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: Text(t.core.nav.settings),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: child),
      ],
    ),
  );

  /// Build a large layout with a persistent [NavigationDrawer].
  Widget _buildLarge(BuildContext _, TabsRouter tabsRouter, int activeIndex) =>
      Scaffold(
        body: Row(
          children: [
            NavigationDrawer(
              selectedIndex: activeIndex,
              onDestinationSelected: tabsRouter.setActiveIndex,
              children: [
                Padding(
                  padding: const .fromLTRB(28, 16, 16, 10),
                  child: Text(
                    t.core.appName,
                    style: const TextStyle(fontSize: 18, fontWeight: .bold),
                  ),
                ),
                NavigationDrawerDestination(
                  icon: const Icon(Icons.dashboard_outlined),
                  selectedIcon: const Icon(Icons.dashboard),
                  label: Text(t.core.nav.dashboard),
                ),
                NavigationDrawerDestination(
                  icon: const Icon(Icons.person_outlined),
                  selectedIcon: const Icon(Icons.person),
                  label: Text(t.core.nav.profile),
                ),
                NavigationDrawerDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: Text(t.core.nav.settings),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
}
