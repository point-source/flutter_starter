/// Display the main dashboard with a personalized welcome greeting.
///
/// This page is the first tab in the authenticated shell. It reads
/// [DashboardViewModel] to show the current user's name in the
/// welcome message. Demonstrates how features access auth state
/// through Riverpod providers.
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_starter/features/dashboard/ui/view_models/dashboard_view_model.dart';
import 'package:flutter_starter/gen/strings.g.dart';

/// The main dashboard page displayed after authentication.
@RoutePage()
class DashboardPage extends ConsumerWidget {
  /// Create a [DashboardPage].
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.dashboard.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.dashboard_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                t.dashboard.welcome(name: name ?? 'User'),
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
