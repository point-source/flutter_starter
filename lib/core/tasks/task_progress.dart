/// Describe the current progress of a background task.
///
/// [TaskProgress] is a sealed hierarchy that supports multiple progress
/// modes without making [TrackedTask] generic:
///
/// - [IndeterminateProgress] for unknown duration (spinners).
/// - [DeterminateProgress] for numeric 0.0–1.0 progress (progress bars).
/// - [PhasedProgress] for labeled steps with optional numeric progress.
///
/// ```dart
/// report(const TaskProgress.indeterminate());
/// report(TaskProgress.determinate(sent / total));
/// report(const TaskProgress.phased('Compressing'));
/// report(TaskProgress.phased('Uploading', sent / total));
/// ```
library;

import 'package:flutter/foundation.dart' show immutable;

/// Represent the progress of a tracked background task.
///
/// Use the named constructors to create the appropriate variant.
sealed class TaskProgress {
  /// Create a [TaskProgress] instance.
  const TaskProgress();

  /// Create indeterminate progress (unknown duration).
  const factory TaskProgress.indeterminate() = IndeterminateProgress;

  /// Create determinate progress with a numeric [fraction] (0.0–1.0).
  const factory TaskProgress.determinate(double fraction) =
      DeterminateProgress;

  /// Create phased progress with a human-readable [label] and optional
  /// numeric [fraction].
  const factory TaskProgress.phased(String label, [double? fraction]) =
      PhasedProgress;
}

/// Progress with no numeric value — duration is unknown.
///
/// Use for tasks where progress cannot be measured, such as network
/// handshakes or indeterminate processing.
@immutable
final class IndeterminateProgress extends TaskProgress {
  /// Create an [IndeterminateProgress].
  const IndeterminateProgress();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is IndeterminateProgress;

  @override
  int get hashCode => (IndeterminateProgress).hashCode;

  @override
  String toString() => 'TaskProgress.indeterminate()';
}

/// Progress with a numeric fraction between 0.0 and 1.0.
///
/// Use for tasks where byte-level or item-level progress is available,
/// such as file uploads or batch processing.
@immutable
final class DeterminateProgress extends TaskProgress {
  /// Create a [DeterminateProgress] with the given [fraction].
  const DeterminateProgress(this.fraction);

  /// The progress fraction, from 0.0 (not started) to 1.0 (complete).
  final double fraction;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeterminateProgress && fraction == other.fraction;

  @override
  int get hashCode => fraction.hashCode;

  @override
  String toString() => 'TaskProgress.determinate($fraction)';
}

/// Progress described by a human-readable label with optional fraction.
///
/// Use for multi-step tasks where each phase has a descriptive name,
/// such as "Compressing", "Encrypting", or "Uploading".
@immutable
final class PhasedProgress extends TaskProgress {
  /// Create a [PhasedProgress] with a [label] and optional [fraction].
  const PhasedProgress(this.label, [this.fraction]);

  /// A human-readable description of the current phase.
  final String label;

  /// An optional numeric fraction within the current phase (0.0–1.0).
  final double? fraction;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhasedProgress &&
          label == other.label &&
          fraction == other.fraction;

  @override
  int get hashCode => Object.hash(label, fraction);

  @override
  String toString() => 'TaskProgress.phased($label, $fraction)';
}
