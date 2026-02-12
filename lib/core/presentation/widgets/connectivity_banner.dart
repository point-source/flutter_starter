/// Display a material banner when the device loses internet connectivity.
///
/// Listens to a Riverpod-managed [ConnectivityResult] stream and shows
/// or hides a [MaterialBanner] accordingly. The banner is automatically
/// dismissed when connectivity is restored.
library;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_banner.g.dart';

/// Stream the current connectivity status from [Connectivity].
///
/// Emits a new list of [ConnectivityResult] values whenever the
/// device's connectivity changes. An empty list or a list containing
/// only [ConnectivityResult.none] indicates no internet access.
@riverpod
Stream<List<ConnectivityResult>> connectivityStatus(Ref _) =>
    Connectivity().onConnectivityChanged;

/// Show a [MaterialBanner] when the device is offline.
///
/// Place this widget near the top of the widget tree (e.g. inside the
/// [Scaffold] body) so the banner appears above page content.
///
/// ```dart
/// Column(
///   children: [
///     const ConnectivityBanner(),
///     Expanded(child: pageContent),
///   ],
/// )
/// ```
class ConnectivityBanner extends ConsumerWidget {
  /// Create a [ConnectivityBanner].
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStatusProvider);

    return connectivityAsync.when(
      data: (results) {
        final isOffline =
            results.contains(ConnectivityResult.none) || results.isEmpty;

        if (!isOffline) return const SizedBox.shrink();

        return MaterialBanner(
          padding: const .symmetric(horizontal: 16, vertical: 8),
          leading: Icon(
            Icons.wifi_off,
            color: Theme.of(context).colorScheme.error,
          ),
          content: const Text('No internet connection'),
          actions: [
            TextButton(
              onPressed: () {
                ref.invalidate(connectivityStatusProvider);
              },
              child: const Text('DISMISS'),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
