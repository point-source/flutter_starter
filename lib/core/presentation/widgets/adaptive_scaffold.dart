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
      compact: (context) => _buildCompact(context, tabsRouter, activeIndex),
      medium: (context) => _buildMedium(context, tabsRouter, activeIndex),
      expanded: (context) => _buildExpanded(context, tabsRouter, activeIndex),
      large: (context) => _buildLarge(context, tabsRouter, activeIndex),
    );
  }

  /// Build a compact layout with a [BottomNavigationBar].
  Widget _buildCompact(
    BuildContext context,
    TabsRouter tabsRouter,
    int activeIndex,
  ) => Scaffold(
    body: child,
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: activeIndex,
      onTap: tabsRouter.setActiveIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    ),
  );

  /// Build a medium layout with a collapsed [NavigationRail].
  Widget _buildMedium(
    BuildContext context,
    TabsRouter tabsRouter,
    int activeIndex,
  ) => Scaffold(
    body: Row(
      children: [
        NavigationRail(
          selectedIndex: activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
          labelType: NavigationRailLabelType.selected,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: Text('Dashboard'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person),
              label: Text('Profile'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: Text('Settings'),
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
    BuildContext context,
    TabsRouter tabsRouter,
    int activeIndex,
  ) => Scaffold(
    body: Row(
      children: [
        NavigationRail(
          selectedIndex: activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
          extended: true,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: Text('Dashboard'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person),
              label: Text('Profile'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: Text('Settings'),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: child),
      ],
    ),
  );

  /// Build a large layout with a persistent [NavigationDrawer].
  Widget _buildLarge(
    BuildContext context,
    TabsRouter tabsRouter,
    int activeIndex,
  ) => Scaffold(
    body: Row(
      children: [
        NavigationDrawer(
          selectedIndex: activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
          children: const [
            Padding(
              padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
              child: Text(
                'Flutter Starter',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            NavigationDrawerDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: Text('Dashboard'),
            ),
            NavigationDrawerDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person),
              label: Text('Profile'),
            ),
            NavigationDrawerDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: Text('Settings'),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: child),
      ],
    ),
  );
}
